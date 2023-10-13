import { Controller } from "@hotwired/stimulus";

const DEBUG = false;

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
    if (this.hasModalOutlet) {
      this.#openModal(scrim, this.modalOutlet);
    }
  }

  modalOutletConnected(modal) {
    if (DEBUG) console.debug("modal connected");

    // When switching modals a target may connect while scrim is already open
    if (this.openValue) return;

    // Capture the scrim and then show the content if the scrim is ready
    if (this.hasScrimOutlet) {
      this.#openModal(this.scrimOutlet, modal);
    }
  }

  modalOutletDisconnected(_) {
    if (DEBUG) console.debug("modal disconnect");

    // When switching modals there may still be content to show
    if (this.hasModalOutlet) return;

    this.openValue = false;
    this.scrimOutlet?.hide();
  }

  openValueChanged(open) {
    this.element.style.display = open ? "flex" : "none";
  }

  dismiss() {
    if (DEBUG) console.debug("dismiss");

    if (!this.hasModalTarget || !this.openValue) return;

    this.modalOutlet?.dismiss();
  }

  async #openModal(scrim, modal) {
    scrim.show(modal.scrimConfig).then(() => (this.openValue = true));
  }

  #clear() {
    if (DEBUG) console.debug("#clear");

    this.element.removeAttribute("src");
    this.element.innerHTML = "";
  }

  // Stimulus 3.2.2 has an issue where outlets do not fire disconnect callbacks
  // when the element is removed from the DOM. We're using targets to work
  // around this issue, but could use outlets in the future when this is
  // resolved.
  modalOutletFor(element) {
    return this.application.getControllerForElementAndIdentifier(
      element,
      "kpop--modal",
    );
  }

  get modalOutlet() {
    return this.modalOutletFor(this.modalTarget);
  }

  get hasModalOutlet() {
    return this.hasModalTarget;
  }

  modalTargetConnected(element) {
    this.modalOutletConnected(this.modalOutletFor(element));
  }

  modalTargetDisconnected(element) {
    this.modalOutletDisconnected(this.modalOutletFor(element));
  }
}
