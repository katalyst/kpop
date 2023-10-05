import { Controller } from "@hotwired/stimulus";

const DEBUG = true;

export default class Kpop__ModalController extends Controller {
  static values = {
    temporary: { type: Boolean, default: true },
  };

  get scrimConfig() {
    return { temporary: this.temporaryValue };
  }

  connect() {
    if (DEBUG) console.debug("modal:connect");

    this.element.toggleAttribute("data-turbo-temporary", this.temporaryValue);
  }

  disconnect() {
    if (this.popped) return;

    if (DEBUG) console.debug("modal:disconnect");

    this.popped = true;
    window.history.back();
  }

  async open(scrim) {
    // Push a new history entry. This will be popped or replaced when the modal is dismissed.
    // Persistent modals push a history entry via Turbo.
    if (this.temporaryValue) {
      if (DEBUG) console.debug("modal:push-state");
      window.history.pushState(window.history.state, "", window.location);
      scrim.show(this.scrimConfig);
    } else {
      return new Promise((resolve) => {
        window.addEventListener(
          "turbo:before-cache",
          () => {
            if (DEBUG) console.debug("modal:visit");
            window.requestAnimationFrame(() => {
              scrim.show(this.scrimConfig);
              resolve();
            });
          },
          { once: true },
        );
      });
    }
  }

  async dismiss() {
    if (this.popped) return;

    if (DEBUG) console.debug("modal:dismiss");
    this.popped = true;

    // set animation state
    this.element.dataset.closing = "";

    // callback for after animation has finished (driven by animation-duration in CSS)
    return new Promise((resolve) => {
      this.element.addEventListener(
        "animationend",
        () => {
          if (DEBUG) console.debug("modal:dismiss-end");

          const event = this.temporaryValue ? "popstate" : "turbo:render";
          window.addEventListener(event, () => resolve(), { once: true });
          window.history.back();
        },
        {
          once: true,
        },
      );
    });
  }

  popstate = () => {
    this.popped = true;

    if (DEBUG) console.debug("modal:popstate");

    // Remove the modal from the DOM if it's a temporary modal.
    if (this.temporaryValue) {
      if (DEBUG) console.debug("modal:popstate-remove");
      this.element.remove();
    }
  };

  beforeCache = () => {
    if (DEBUG) console.debug("modal:before-cache");

    // Modal has already animated (if it's going to), we won't see another frame
    // before turbo pops state, so we can safely restore the dom state to the
    // "rendered" version.
    delete this.element.dataset.closing;
  };

  beforeVisit = (e) => {
    if (this.popped) return;

    if (DEBUG) console.debug("modal:before-visit");

    // visit fires when persistent modals load, so we need to ignore those.
    if (e.detail.url === this.element.closest("turbo-frame").src) return;

    if (DEBUG) console.debug("modal:visit", e.detail.url);

    e.preventDefault();
    this.popped = true;
    if (this.temporaryValue) {
      Turbo.visit(e.detail.url, { action: "replace" });
    } else {
      Turbo.visit(e.detail.url, { action: "advance" });
    }

    if (DEBUG) console.debug("modal:visit-end");
  };
}
