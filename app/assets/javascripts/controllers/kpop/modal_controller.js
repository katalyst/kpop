import { Controller } from "@hotwired/stimulus";

const DEBUG = false;

export default class Kpop__ModalController extends Controller {
  static values = {
    temporary: { type: Boolean, default: true },
  };

  get scrimConfig() {
    return { temporary: this.temporaryValue };
  }

  connect() {
    if (DEBUG) console.debug("modal connect");

    this.element.toggleAttribute("data-turbo-temporary", this.temporaryValue);

    // Push a new history entry. This will be popped or replaced when the modal is dismissed.
    // Persistent modals push a history entry via Turbo.
    if (this.temporaryValue) {
      window.history.pushState({}, "", window.location);
    }

    // Capture pops so we can dismiss the modal.
    window.addEventListener("popstate", this.popstate);

    // Capture visits so we can replace history.
    window.addEventListener("turbo:before-visit", this.beforeVisit);
  }

  disconnect() {
    if (DEBUG) console.debug("modal disconnect");

    window.removeEventListener("popstate", this.popstate);
    window.removeEventListener("turbo:before-visit", this.beforeVisit);

    if (!this.popped) {
      this.dismiss();
    }
  }

  dismiss() {
    if (DEBUG) console.debug("modal dismiss");

    if (!this.popped) {
      this.popped = true;
      window.history.back();
    }
  }

  popstate = () => {
    this.popped = true;

    if (DEBUG) console.debug("modal popped");

    // Remove the modal from the DOM if it's a temporary modal.
    if (this.temporaryValue) {
      this.element.remove();
    }
  };

  beforeVisit = (e) => {
    if (this.popped) return;

    // visit fires when persistent modals load, so we need to ignore those.
    if (e.detail.url === this.element.closest("turbo-frame").src) return;

    if (DEBUG) console.debug("visiting", e.detail.url);

    e.preventDefault();
    this.popped = true;
    Turbo.visit(e.detail.url, { action: "replace" });
  };
}
