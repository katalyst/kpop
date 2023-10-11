import { Controller } from "@hotwired/stimulus";

const DEBUG = true;

export default class Kpop__FrameController extends Controller {
  static outlets = ["scrim"];
  static targets = ["modal"];
  static values = {
    open: Boolean,
  };

  scrimOutletConnected(scrim) {
    if (DEBUG) console.debug("scrim connected");

    // return if already initialized
    if (this.openValue) return;

    // Capture the scrim and then show the content
    if (this.hasModalTarget) {
      scrim.show().then(() => (this.openValue = true));
    }
  }

  modalTargetConnected() {
    if (DEBUG) console.debug("modal connected");

    // When switching modals a target may connect while scrim is already open
    if (this.openValue) return;

    // Capture the scrim and then show the content if the scrim is ready
    this.scrimOutlet?.show()?.then(() => (this.openValue = true));
  }

  modalTargetDisconnected() {
    if (DEBUG) console.debug("modal disconnect");

    // When switching modals there may still be content to show
    if (this.hasModalTarget) return;

    this.openValue = false;
    this.scrimOutlet?.hide();
  }

  openValueChanged(open) {
    if (DEBUG) console.debug("state:", open ? "open" : "close");

    this.element.style.display = open ? "flex" : "none";
  }

  dismiss() {
    if (DEBUG) console.debug("dismiss");

    if (!this.hasModalTarget || !this.openValue) return;

    this.#clear();
  }

  #clear() {
    if (DEBUG) console.debug("#clear");

    this.element.removeAttribute("src");
    this.element.innerHTML = "";
  }
}
