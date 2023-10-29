import { Controller } from "@hotwired/stimulus";

import DEBUG from "../debug";

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
  };

  connect() {
    if (DEBUG) console.debug("scrim:connect");

    this.defaultZIndexValue = this.zIndexValue;
    this.defaultCaptiveValue = this.captiveValue;

    this.element.scrim = this;
  }

  disconnect() {
    if (DEBUG) console.debug("scrim:disconnect");

    delete this.element.scrim;
  }

  async show({
    captive = this.defaultCaptiveValue,
    zIndex = this.defaultZIndexValue,
    top = window.scrollY,
    animate = true,
  } = {}) {
    if (DEBUG) console.debug("scrim:before-show");

    // hide the scrim before opening the new one if it's already open
    if (this.openValue) {
      await this.hide({ animate });
    }

    // update internal state
    this.openValue = true;

    // notify listeners of pending request
    this.dispatch("show", { bubbles: true });

    if (DEBUG) console.debug("scrim:show-start");

    // update state, perform style updates
    this.#show(captive, zIndex, top);

    if (animate) {
      // animate opening
      // this will trigger an animationEnd event via CSS that completes the open
      this.element.dataset.showAnimating = "";

      await new Promise((resolve) => {
        this.element.addEventListener("animationend", () => resolve(), {
          once: true,
        });
      });

      delete this.element.dataset.showAnimating;
    }

    if (DEBUG) console.debug("scrim:show-end");
  }

  async hide({ animate = true } = {}) {
    if (!this.openValue || this.element.dataset.hideAnimating) return;

    if (DEBUG) console.debug("scrim:before-hide");

    // notify listeners of pending request
    this.dispatch("hide", { bubbles: true });

    if (DEBUG) console.debug("scrim:hide-start");

    if (animate) {
      // set animation state
      // this will trigger an animationEnd event via CSS that completes the hide
      this.element.dataset.hideAnimating = "";

      await new Promise((resolve) => {
        this.element.addEventListener("animationend", () => resolve(), {
          once: true,
        });
      });

      delete this.element.dataset.hideAnimating;
    }

    this.#hide();

    this.openValue = false;

    if (DEBUG) console.debug("scrim:hide-end");
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

  /**
   * Clips body to viewport size and sets the z-index
   */
  #show(captive, zIndex, top) {
    this.captiveValue = captive;
    this.zIndexValue = zIndex;
    this.scrollY = top;

    this.previousPosition = document.body.style.position;
    this.previousTop = document.body.style.top;
    this.previousScrollBehavior = document.body.style.overscrollBehavior;

    this.element.style.zIndex = this.zIndexValue;
    document.body.style.top = `-${top}px`;
    document.body.style.position = "fixed";
    document.body.style.overscrollBehavior = "none";
    document.body.parentElement.style.overscrollBehavior = "none";
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
    resetStyle(document.body, "overscroll-behavior", null);
    resetStyle(document.body.parentElement, "overscroll-behavior", null);

    window.scrollTo({ left: 0, top: this.scrollY, behavior: "instant" });

    delete this.scrollY;
    delete this.previousPosition;
    delete this.previousTop;
    delete this.previousScrollBehavior;
  }
}

function resetStyle(element, property, previousValue) {
  if (previousValue) {
    element.style.setProperty(property, previousValue);
  } else {
    element.style.removeProperty(property);
  }
}
