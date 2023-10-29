import { Controller } from "@hotwired/stimulus";

import DEBUG from "../debug";
import { ContentModal } from "../modals/content_modal";
import { FrameModal } from "../modals/frame_modal";

export default class Kpop__FrameController extends Controller {
  static outlets = ["scrim"];
  static targets = ["modal"];
  static values = {
    open: Boolean,
  };

  initialize() {
    this.threshold = 100; // Define the threshold for swipe to dismiss
    this.initialY = 0;
  }

  connect() {
    this.debug("connect", this.element.src);

    this.element.kpop = this;

    // restoration visit
    if (this.element.src && this.element.complete) {
      this.debug("new frame modal", this.element.src);
      this.open(new FrameModal(this.element.id, this.element.src), {
        animate: false,
      });
    } else {
      const element = this.element.querySelector(
        "[data-controller*='kpop--modal']"
      );
      if (element) {
        this.debug("new content modal", window.location.pathname);
        this.open(new ContentModal(this.element.id), { animate: false });
      }
    }

  }

  disconnect() {
    this.debug("disconnect");

    delete this.element.kpop;
    delete this.modal;
  }

  scrimOutletConnected(scrim) {
    this.debug("scrim-connected");

    this.scrimConnected = true;

    if (this.openValue) scrim.show({ animate: false });
  }

  openValueChanged(open) {
    this.debug("open-changed", open);

    this.element.parentElement.style.display = open ? "flex" : "none";
  }

  async open(modal, { animate = true } = {}) {
    if (this.isOpen) {
      this.debug("skip open as already open");
      return false;
    }

    return (this.opening ||= this.#nextFrame(() =>
      this.#open(modal, { animate })
    ));
  }

  async dismiss({ animate = true, reason = "" } = {}) {
    if (!this.isOpen) {
      this.debug("skip dismiss as already closed");
      return false;
    }

    return (this.dismissing ||= this.#nextFrame(() =>
      this.#dismiss({ animate, reason })
    ));
  }

  // EVENTS

  popstate(event) {
    this.modal?.popstate(this, event);
  }

  beforeFrameRender(event) {
    this.debug("before-frame-render", event.detail.newFrame.baseURI);

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
    event.detail.render = (stream) => {
      (this.dismissing || Promise.resolve()).then(() => {
        this.debug("stream-render", stream);
        resume(stream);
      });
    };
  }

  beforeVisit(e) {
    this.debug("before-visit", e.detail.url);

    // ignore visits to the current frame, these fire when the frame navigates
    if (e.detail.url === this.element.src) return;

    // ignore unless we're open
    if (!this.isOpen) return;

    this.modal.beforeVisit(this, e);
  }

  frameLoad(event) {
    this.debug("frame-load");

    return this.open(new FrameModal(this.element.id, this.element.src), {
      animate: true,
    });
  }

  get isOpen() {
    return this.openValue && !this.dismissing;
  }

  async #open(modal, { animate = true } = {}) {
    this.debug("open-start", { animate });

    const scrim = this.scrimConnected && this.scrimOutlet;

    this.modal = modal;
    this.openValue = true;

    await modal.open({ animate });
    await scrim?.show({ animate });

    delete this.opening;

    if(this.element.classList.contains("side-panel")) {
      this.element.addEventListener("touchstart", this.onTouchStart);
      this.element.addEventListener("touchmove", this.handleSwipe);
      this.element.addEventListener("touchend", this.onTouchEnd);
    }

    this.debug("open-end");
  }

  async #dismiss({ animate = true, reason = "" } = {}) {
    this.debug("dismiss-start", { animate, reason });

    if (!this.modal) {
      console.warn("modal missing on dismiss");
      if (DEBUG) debugger;
    }

    await this.scrimOutlet.hide({ animate });
    await this.modal?.dismiss();

    this.openValue = false;
    this.modal = null;
    delete this.dismissing;

    this.element.removeEventListener("touchstart", this.onTouchStart);
    this.element.removeEventListener("touchmove", this.handleSwipe);
    this.element.removeEventListener("touchend", this.onTouchEnd);

    this.debug("dismiss-end");
  }

  handleSwipe = (event) => {
    const touchEndY = event.changedTouches[0].clientY;
    const swipeDistance = touchEndY - this.initialY;

    // Update the panel's position based on swipe distance
    this.element.style.transform = `translateY(${Math.max(0, swipeDistance)}px)`;

    this.willDismiss = swipeDistance > this.threshold;
  }

  onTouchStart = (event) => {
    // event.preventDefault();
    this.element.style.transition = "";
    this.initialY = event.touches[0].clientY; // Store initial touch position
    this.willDismiss = false;
  }

  onTouchEnd = () => {
    if (this.willDismiss) {
      this.dismiss({ animate: true, reason: "swipe-down" })
    }else{
      this.element.style.transition = "transform 0.125s linear";
      this.element.style.transform = "translateY(0px)"; // Reset transform property
    }
  }

  async #nextFrame(callback) {
    // return Promise.resolve().then(callback);
    return new Promise(window.requestAnimationFrame).then(callback);
  }

  debug(event, ...args) {
    if (DEBUG) console.debug(`FrameController:${event}`, ...args);
  }
}
