import { Controller } from "@hotwired/stimulus";

const DEBUG = true;

/**
 * Scrim controller wraps an element that creates a whole page layer.
 * It is intended to be used behind a modal or nav drawer.
 *
 * If the Scrim element receives a click event, it automatically triggers "scrim:hide".
 *
 * You can show and hide the scrim programmatically by calling show/hide on the controller, e.g. using an outlet.
 *
 * If you need to respond to the scrim showing or hiding you should subscribe to "scrim:show" and "scrim:hide".
 */
export default class ScrimController extends Controller {
  static values = {
    open: Boolean,
    captive: Boolean,
    zIndex: Number,
    temporary: { type: Boolean, default: true },
  };

  connect() {
    if (DEBUG) console.debug("scrim:connect");

    this.defaultZIndexValue = this.zIndexValue;
    this.defaultCaptiveValue = this.captiveValue;
    this.defaultTemporaryValue = this.temporaryValue;
  }

  show({
    captive = this.defaultCaptiveValue,
    zIndex = this.defaultZIndexValue,
    top = window.scrollY,
    temporary = this.defaultTemporaryValue,
  } = {}) {
    if (DEBUG) console.debug("scrim:before-show");

    // hide the scrim before opening the new one if it's already open
    if (this.openValue) {
      this.hide();
      delete this.element.dataset.hideAnimating; // cancel hide animation
    }

    // if the scrim is still open, abort
    if (this.openValue) return;

    // update internal state to break event cycles
    this.openValue = true;

    // notify listeners of pending request
    this.dispatch("show", { bubbles: true });

    if (DEBUG) console.debug("scrim:show-start");

    // update state, perform style updates
    this.#show(captive, zIndex, top, temporary);

    // animate opening
    // this will trigger an animationEnd event via CSS that completes the open
    this.element.dataset.showAnimating = "";
  }

  hide() {
    if (!this.openValue) return;

    if (DEBUG) console.debug("scrim:before-hide");

    // update internal state to break event cycles
    this.openValue = false;

    // notify listeners of pending request
    this.dispatch("hide", { bubbles: true });

    if (DEBUG) console.debug("scrim:hide-start");

    // set animation state
    // this will trigger an animationEnd event via CSS that completes the hide
    this.element.dataset.hideAnimating = "";
  }

  beforeCache() {
    if (DEBUG) console.debug("scrim:before-cache");

    // hide the scrim if the current modal is not cacheable
    if (this.temporaryValue) this.hide();

    // jump directly to the end-state of the animation, if any
    this.animationEnd();
  }

  dismiss(event) {
    if (DEBUG) console.debug("scrim:dismiss");

    if (!this.captiveValue) this.dispatch("dismiss", { bubbles: true });
  }

  escape(event) {
    if (
      event.key === "Escape" &&
      !this.captiveValue &&
      !event.defaultPrevented
    ) {
      this.dispatch("dismiss", { bubbles: true });
    }
  }

  animationEnd() {
    if (this.element.dataset.hideAnimating === "") {
      if (DEBUG) console.debug("scrim:hide-end");
      delete this.element.dataset.hideAnimating;

      // update state, perform style updates
      this.#hide();

      if (DEBUG) console.debug("scrim:#hide-end");
    }

    if (this.element.dataset.showAnimating === "") {
      if (DEBUG) console.debug("scrim:show-end");
      delete this.element.dataset.showAnimating;
    }
  }

  /**
   * Clips body to viewport size and sets the z-index
   */
  #show(captive, zIndex, top, temporary) {
    this.captiveValue = captive;
    this.zIndexValue = zIndex;
    this.scrollY = top;
    this.temporaryValue = temporary;

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
    this.temporaryValue = this.defaultTemporaryValue;

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
