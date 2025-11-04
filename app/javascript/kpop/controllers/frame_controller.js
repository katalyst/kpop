import { Controller } from "@hotwired/stimulus";

import { ContentModal } from "../modals/content_modal";
import { FrameModal } from "../modals/frame_modal";

import debug from "../utils/debug";

export default class Kpop__FrameController extends Controller {
  static values = {
    open: Boolean,
  };

  connect() {
    this.debug("connect", this.element.src);

    this.element.kpop = this;

    // allow our code to intercept frame navigation requests before dom changes
    installNavigationInterception(this);

    const dialog = this.element.querySelector("dialog");

    if (this.element.src && dialog) {
      this.debug("new frame modal", this.element.src);
      FrameModal.connect(this, dialog, this.element.src).then(() => {});
    } else if (dialog) {
      this.debug("new content modal", dialog);
      ContentModal.connect(this, dialog);
    } else {
      this.debug("no modal");
      this.clear();
    }
  }

  disconnect() {
    this.debug("disconnect", this.element.src);

    delete this.element.kpop;
    delete this.modal;
  }

  openValueChanged(open) {
    this.debug("open-changed", open);
  }

  /**
   * Animate an attached modal into the foreground. Returns a promise that
   * resolves when the animation is complete.
   *
   * @param modal
   * @param animate
   * @returns {Promise<Boolean>}
   */
  async open(modal, { animate = true } = {}) {
    if (this.isOpen) {
      this.debug("skip open as already open");
      this.modal ||= modal;
      return false;
    }

    await this.dismissing;

    return (this.opening ||= Promise.resolve().then(() => {
      modal.connect();
      return this.#open(modal, { animate });
    }));
  }

  /**
   * Cause a modal to hide. Returns a promise that will resolve when the
   * animation (if requested) is finished.
   *
   * If the modal is already animating out, returns the existing promise instead.
   *
   * @param {Boolean} animate
   * @param {String} reason
   * @returns {Promise}
   */
  async dismiss({ animate = true, reason = "" } = {}) {
    this.debug("event:dismiss", reason);

    if (!this.isOpen) {
      this.debug("skip dismiss as already closed");
      return false;
    }

    await this.opening;

    return (this.dismissing ||= this.#dismiss({ animate, reason }));
  }

  /**
   * Clean up after a modal is finished dismissing.
   */
  clear({ reason = "" } = {}) {
    this.debug("event:clear", reason);

    // clear the src from the frame (if any)
    this.element.src = "";
    this.element.innerHTML = "";

    // mark the modal as hidden
    this.openValue = false;

    // unset modal
    if (this.modal) this.modal.disconnect();
    delete this.modal;
    delete this.dismissing;
  }

  // EVENTS

  /**
   * Incoming frame render, dismiss the current modal (if any) first.
   *
   * We're starting the actual visit
   *
   * @param event turbo:before-render
   */
  beforeFrameRender(event) {
    this.debug("before-frame-render", event.detail.newFrame.baseURI);

    if (event.detail.newFrame.id !== this.element.id) return;

    event.preventDefault();

    this.dismiss({ animate: true, reason: "before-frame-render" }).then(() => {
      this.debug("resume-frame-render", event.detail.newFrame.baseURI);
      event.detail.resume();
    });
  }

  beforeStreamRender(event) {
    this.debug("before-stream-render", event.detail);

    const resume = event.detail.render;

    // Defer rendering until dismiss is complete.
    // Dismiss may change history so we need to wait for it to complete to avoid
    // losing DOM changes on restoration visits.
    event.detail.render = async (stream) => {
      await this.dismissing;

      this.debug("stream-render", stream);

      await resume(stream);
    };
  }

  beforeVisit(e) {
    this.debug("before-visit", e.detail.url);

    // ignore visits to the current frame, these fire when the frame navigates
    if (e.detail.url === this.element.src) return;

    const url = new URL(e.detail.url.toString(), document.baseURI);
    if (url.pathname === "/resume_historical_location") {
      e.preventDefault();
      return this.dismiss();
    }

    // ignore unless we're open
    if (!this.isOpen) return;

    this.modal.beforeVisit(this, e);
  }

  frameLoad(e) {
    this.debug("frame-load");

    FrameModal.load(this, e.target.firstElementChild, e.target.src).then(
      () => {},
    );
  }

  /**
   * Outgoing fetch request. Capture the initiator so we can return focus if it causes a modal to show.
   */
  beforeFetchRequest() {
    const focusElement = document.activeElement;

    if (focusElement === document.body) {
      delete this.lastFetchFocusRef;
    } else {
      this.lastFetchFocusRef = new WeakRef(focusElement);
    }
  }

  get isOpen() {
    return this.openValue && !this.dismissing;
  }

  async #open(modal, { animate = true } = {}) {
    this.debug("open-start", { animate });

    this.previousFocusRef =
      document.activeElement === document.body
        ? this.lastFetchFocusRef
        : new WeakRef(document.activeElement);
    this.debug("capture focus", this.previousFocusRef?.deref());

    this.modal = modal;
    this.openValue = true;

    // Set turbo-frame[src] without causing a load event
    this.element.delegate.sourceURL = this.modal.src;

    await modal.open({ animate });

    delete this.opening;

    this.debug("open-end");

    autofocus(this.modal?.element)?.focus();

    // Detect https://github.com/hotwired/turbo-rails/issues/580
    if (Turbo.session.view.forceReloaded) {
      console.error("Turbo-Frame response is incompatible with current page");
    }

    return true;
  }

  async #dismiss({ animate = true, reason = "" } = {}) {
    this.debug("dismiss-start", { animate, reason });

    // if this element is detached then we've experienced a turbo navigation
    if (!this.element.isConnected) {
      this.debug("skip dismiss, element detached");
      return;
    }

    if (!this.modal) {
      console.warn("modal missing on dismiss");
    }

    await this.modal?.dismiss({ animate });

    this.clear();

    this.previousFocusRef?.deref()?.focus();
    this.debug("restore focus", this.previousFocusRef?.deref());
    delete this.previousFocusRef;

    this.debug("dismiss-end");
  }

  async #nextFrame(callback) {
    return new Promise(window.requestAnimationFrame).then(callback);
  }

  get debug() {
    return debug("FrameController");
  }
}

/**
 * Monkey patch for Turbo#FrameController.
 *
 * Intercept calls to linkClickIntercepted(element, location) and ensures
 * that src is cleared if the frame is busy so that we don't restore an
 * in-progress src on restoration visits.
 *
 * See Turbo issue: https://github.com/hotwired/turbo/issues/1055
 *
 * @param controller FrameController
 */
function installNavigationInterception(controller) {
  const TurboFrameController =
    controller.element.delegate.constructor.prototype;

  if (TurboFrameController._linkClickIntercepted) return;

  TurboFrameController._linkClickIntercepted =
    TurboFrameController.linkClickIntercepted;
  TurboFrameController.linkClickIntercepted = function (element, location) {
    // #findFrameElement
    const id =
      element?.getAttribute("data-turbo-frame") ||
      this.element.getAttribute("target");
    let frame = document.getElementById(id);
    if (!(frame instanceof Turbo.FrameElement)) {
      frame = this.element;
    }

    if (frame.kpop) {
      frame.kpop.debug("navigate-frame %s => %s", frame.src, location);
      FrameModal.visit(location, frame.kpop, frame, () => {
        TurboFrameController._linkClickIntercepted.call(
          this,
          element,
          location,
        );
      });
    } else {
      TurboFrameController._linkClickIntercepted.call(this, element, location);
    }
  };
}

function autofocus(container) {
  if (!container) return null;

  return (
    container.querySelector("[autofocus]") ??
    container.querySelector("button:not([disabled])")
  );
}
