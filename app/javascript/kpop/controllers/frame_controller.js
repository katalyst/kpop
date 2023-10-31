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

  connect() {
    this.debug("connect", this.element.src);

    this.element.kpop = this;
    installNavigationInterception(this.element);

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

    if (this.openValue) {
      scrim.show({ animate: false });
    } else {
      scrim.hide({ animate: false });
    }
  }

  openValueChanged(open) {
    this.debug("open-changed", open);

    this.element.parentElement.style.display = open ? "flex" : "none";
  }

  async open(modal, { animate = true } = {}) {
    if (this.isOpen) {
      this.debug("skip open as already open");
      this.modal ||= modal;
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

  navigateFrame(element, location) {
    this.debug("navigate-frame", this.element.src, location);

    // Ensure that turbo doesn't cache the frame in a loading state by cancelling
    // the current request (if any) by clearing the src.
    // Known issue: this won't work if the frame was previously rendering a useful src.
    if (this.element.hasAttribute("busy")) {
      this.element.src = "";
    }

    // Delay turbo's navigateFrame until next tick to let the src change settle.
    return Promise.resolve();
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

    this.debug("open-end");
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
      if (DEBUG) debugger;
    }

    await this.scrimOutlet.hide({ animate });
    await this.modal?.dismiss();

    this.openValue = false;
    this.modal = null;
    delete this.dismissing;

    this.debug("dismiss-end");
  }

  async #nextFrame(callback) {
    return new Promise(window.requestAnimationFrame).then(callback);
  }

  debug(event, ...args) {
    if (DEBUG) console.debug(`FrameController:${event}`, ...args);
  }
}

/**
 * Monkey patch for Turbo#FrameController.
 *
 * Intercept calls to navigateFrame(element, location) and ensures that src is
 * cleared if the frame is busy so that we don't restore an in-progress src on
 * restoration visits.
 *
 * See Turbo issue: https://github.com/hotwired/turbo/issues/1055
 *
 * @param frameElement turbo-frame element
 */
function installNavigationInterception(frameElement) {
  if (frameElement.delegate._navigateFrame === undefined) {
    frameElement.delegate._navigateFrame = frameElement.delegate.navigateFrame;
    frameElement.delegate.navigateFrame = async (element, location) => {
      await frameElement.kpop?.navigateFrame(element, location);
      return frameElement.delegate._navigateFrame.call(
        frameElement.delegate,
        element,
        location
      );
    };
  }
}
