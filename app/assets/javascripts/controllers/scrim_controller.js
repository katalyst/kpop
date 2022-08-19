import { Controller } from "@hotwired/stimulus"

/**
 * Scrim controller wraps an element that creates a whole page layer.
 * It is intended to be used behind a modal or nav drawer.
 *
 * If the Scrim element receives a click event, it automatically triggers "scrim:hide".
 *
 * You can show and hide the scrim programmatically by sending "scrim:show" and "scrim:hide" events to the window or by
 * calling the provided methods. If you need to respond to the scrim showing or hiding you should subscribe to these
 * events.
 */
class ScrimController extends Controller {
  static targets = ["scrim"];

  show(event) {
    clipScreen(this);
    delete this.scrimTarget.dataset.hidden;
    if (event.detail.dismissable) {
      this.scrimTarget.dataset.dismissable = "";
    }
  }

  hide(event = null) {
    delete this.scrimTarget.dataset.dismissable;
    this.scrimTarget.dataset.hidden = "";
    unclipScreen(this);
  }

  onClick(event) {
    if (this.scrimTarget.dataset.dismissable === "") {
      window.dispatchEvent(new Event("scrim:hide"));
    }
  }

  disconnect() {
    this.hide();
    super.disconnect();
  }
}

/**
 * Show the scrim element
 */
function showScrim(dismiss = true) {
  window.dispatchEvent(new CustomEvent("scrim:show", { detail: { dismissable: dismiss } }));
}

/**
 * Hide the scrim element programmatically.
 */
function hideScrim() {
  window.dispatchEvent(new Event("scrim:hide"));
}

/**
 * Clips body to viewport size
 */
function clipScreen(controller) {
  controller.previousHeight = document.body.style.height || "unset";
  controller.previousOverflow = document.body.style.overflow || "unset";
  document.body.style.height = "100vh";
  document.body.style.overflow = "hidden";
}

/**
 * Unclips body to viewport size
 */
function unclipScreen(controller) {
  document.body.style.height = controller.previousHeight;
  document.body.style.overflow = controller.previousOverflow;
}

export { ScrimController as default, showScrim, hideScrim }
