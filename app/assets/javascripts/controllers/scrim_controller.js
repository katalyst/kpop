import { Controller } from "@hotwired/stimulus";

const DEBUG = false;

/**
 * Scrim controller wraps an element that creates a whole page layer.
 * It is intended to be used behind a modal or nav drawer.
 *
 * If the Scrim element receives a click event, it automatically triggers "scrim:hide".
 *
 * You can show and hide the scrim programmatically by sending "scrim:request:show" and "scrim:request:hide" events to
 * the window or by calling the provided methods.
 *
 * If you need to respond to the scrim showing or hiding you should subscribe to "scrim:show" and "scrim:hide".
 */
export default class ScrimController extends Controller {
  static values = {
    open: Boolean,
    captive: Boolean,
    zIndex: Number,
  };

  /**
   * Show the scrim element. Returns true if successful.
   */
  static showScrim({
    dismiss = true,
    zIndex = undefined,
    top = undefined,
  } = {}) {
    return window.dispatchEvent(
      new CustomEvent("scrim:request:show", {
        cancelable: true,
        detail: { captive: !dismiss, zIndex: zIndex, top: top },
      })
    );
  }

  /**
   * Hide the scrim element. Returns true if successful.
   */
  static hideScrim() {
    return window.dispatchEvent(
      new CustomEvent("scrim:request:hide", { cancelable: true })
    );
  }

  connect() {
    this.defaultZIndexValue = this.zIndexValue;
    this.defaultCaptiveValue = this.captiveValue;
  }

  show(request) {
    if (DEBUG) console.debug("request show scrim");

    // hide the scrim before opening the new one if it's already open
    if (this.openValue) this.hide(request);

    // if the scrim is still open, abort
    if (this.openValue) return;

    // update internal state to break event cycles
    this.openValue = true;

    // notify listeners of pending request
    this.dispatch("show", { bubbles: true });

    if (DEBUG) console.debug("show scrim");

    // update state, perform style updates
    this.#show(request.detail);
  }

  hide(request) {
    if (!this.openValue) return;

    if (DEBUG) console.debug("request hide scrim");

    // update internal state to break event cycles
    this.openValue = false;

    // notify listeners of pending request
    this.dispatch("hide", { bubbles: true });

    if (DEBUG) console.debug("hide scrim");

    // update state, perform style updates
    this.#hide();
  }

  dismiss(event) {
    if (!this.captiveValue) this.hide(event);
  }

  escape(event) {
    if (event.key === "Escape" && !this.captiveValue && !event.defaultPrevented)
      this.hide(event);
  }

  /**
   * Clips body to viewport size and sets the z-index
   */
  #show({
    captive = this.defaultCaptiveValue,
    zIndex = this.defaultZIndexValue,
    top = window.scrollY,
  }) {
    this.captiveValue = captive;
    this.zIndexValue = zIndex;
    this.scrollY = top;

    this.previousPosition = document.body.style.position;
    this.previousTop = document.body.style.top;

    this.element.style.zIndex = this.zIndexValue;
    document.body.style.top = `-${top}px`;
    document.body.style.position = "fixed";
  }

  /**
   * Unclips body from viewport size and unsets the z-index
   */
  #hide() {
    this.captiveValue = this.defaultCaptiveValue;
    this.zIndexValue = this.defaultZIndexValue;

    resetStyle(this.element, "z-index", null);
    resetStyle(document.body, "position", null);
    resetStyle(document.body, "top", null);
    window.scrollTo({ left: 0, top: this.scrollY, behavior: "instant" });

    delete this.scrollY;
    delete this.previousPosition;
    delete this.previousTop;
  }
}

function resetStyle(element, property, previousValue) {
  if (previousValue) {
    element.style.setProperty(property, previousValue);
  } else {
    element.style.removeProperty(property);
  }
}
