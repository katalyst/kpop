import { Controller } from "stimulus"

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
    delete this.scrimTarget.dataset.hidden;
  }

  hide(event) {
    this.scrimTarget.dataset.hidden = "";
  }

  onClick(event) {
    window.dispatchEvent(new Event("scrim:hide"));
  }
}

/**
 * Show the scrim element
 */
function showScrim() {
  window.dispatchEvent(new Event("scrim:show"));
}

/**
 * Hide the scrim element programmatically.
 */
function hideScrim() {
  window.dispatchEvent(new Event("scrim:hide"));
}

export { ScrimController as default, showScrim, hideScrim }
