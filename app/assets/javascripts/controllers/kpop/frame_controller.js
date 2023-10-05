import { Controller } from "@hotwired/stimulus";

const DEBUG = true;

export default class Kpop__FrameController extends Controller {
  static outlets = ["scrim"];
  static targets = ["modal"];
  static values = {
    open: Boolean,
  };

  scrimOutletConnected(scrim) {
    if (DEBUG) console.debug("frame:scrim-connected");

    // return if already initialized
    if (this.openValue) return;

    // Capture the scrim and then show the content
    if (this.hasModalOutlet) {
      this.#openModal(scrim, this.modalOutlet);
    }
  }

  modalOutletConnected(modal) {
    if (DEBUG) console.debug("frame:modal-connected");

    // When switching modals a target may connect while scrim is already open
    if (this.openValue) return;

    // Capture the scrim and then show the content if the scrim is ready
    if (this.hasScrimOutlet) {
      this.#openModal(this.scrimOutlet, modal);
    }
  }

  modalOutletDisconnected(_) {
    if (DEBUG) console.debug("frame:modal-disconnect");

    // When switching modals there may still be content to show
    if (this.hasModalOutlet) return;

    this.openValue = false;
    this.scrimOutlet?.hide();
  }

  openValueChanged(open) {
    if (DEBUG) console.debug("frame:open-changed");

    this.element.style.display = open ? "flex" : "none";
  }

  async dismiss() {
    if (DEBUG) console.debug("frame:dismiss-start");

    if (!this.hasModalTarget || !this.openValue) return;

    return this.modalOutlet?.dismiss();
  }

  async #openModal(scrim, modal) {
    if (DEBUG) console.debug("frame:#open-start");
    await modal.open(scrim);
    this.openValue = true;
    if (DEBUG) console.debug("frame:#open-end");
  }

  #clear() {
    if (DEBUG) console.debug("frame:#clear");

    this.element.removeAttribute("src");
    this.element.removeAttribute("complete");
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
