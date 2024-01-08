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

    // allow our code to intercept frame navigation requests before dom changes
    installNavigationInterception(this);

    if (this.element.src && this.element.complete) {
      this.debug("new frame modal", this.element.src);
      FrameModal.connect(this, this.element);
    } else if (this.modalElements.length > 0) {
      this.debug("new content modal", window.location.pathname);
      ContentModal.connect(this, this.element);
    } else {
      this.debug("no modal");
      this.clear();
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

    await this.dismissing;

    return (this.opening ||= this.#nextFrame(() =>
      this.#open(modal, { animate }),
    ));
  }

  async dismiss({ animate = true, reason = "" } = {}) {
    if (!this.isOpen) {
      this.debug("skip dismiss as already closed");
      return false;
    }

    await this.opening;

    return (this.dismissing ||= this.#nextFrame(() =>
      this.#dismiss({ animate, reason }),
    ));
  }

  async clear() {
    // clear the src from the frame (if any)
    this.element.src = "";

    // remove any open modal(s)
    this.modalElements.forEach((element) => element.remove());

    // mark the modal as hidden (will hide scrim on connect)
    this.openValue = false;

    // close the scrim, if connected
    if (this.scrimConnected) {
      return this.scrimOutlet.hide({ animate: false });
    }

    // unset modal
    this.modal = null;
  }

  // EVENTS

  popstate(event) {
    this.modal?.popstate(this, event);
  }

  /**
   * Incoming frame render, dismiss the current modal (if any) first.
   *
   * We're starting the actual visit
   *
   * @param event turbo:before-render
   */
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

    const modal = new FrameModal(this.element.id, this.element.src);

    window.addEventListener(
      "turbo:visit",
      (e) => {
        this.open(modal, { animate: true });
      },
      { once: true },
    );
  }

  get isOpen() {
    return this.openValue && !this.dismissing;
  }

  get modalElements() {
    return this.element.querySelectorAll("[data-controller*='kpop--modal']");
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
 * @param controller FrameController
 */
function installNavigationInterception(controller) {
  const TurboFrameController =
    controller.element.delegate.constructor.prototype;

  if (TurboFrameController._navigateFrame) return;

  TurboFrameController._navigateFrame = TurboFrameController.navigateFrame;
  TurboFrameController.navigateFrame = function (element, url, submitter) {
    const frame = this.findFrameElement(element, submitter);

    if (frame.kpop) {
      FrameModal.visit(url, frame.kpop, frame, () => {
        TurboFrameController._navigateFrame.call(this, element, url, submitter);
      });
    } else {
      TurboFrameController._navigateFrame.call(this, element, url, submitter);
    }
  };
}
