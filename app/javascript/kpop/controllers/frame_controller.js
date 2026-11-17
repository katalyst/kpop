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
    if (this.modal?.src === this.element.src) this.element.src = "";
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

function autofocus(container) {
  if (!container) return null;

  return (
    container.querySelector("[autofocus]") ??
    container.querySelector("button:not([disabled])")
  );
}
