import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

import DEBUG from "../debug";
import { ContentModal } from "../modals/content_modal";
import { FrameModal } from "../modals/frame_modal";
import { StreamModal } from "../modals/stream_modal";
import { StreamRenderer } from "../modals/stream_renderer";

Turbo.StreamActions.kpop_open = function () {
  const frame = () => {
    return this.targetElements[0];
  };
  const animate = !frame?.kpop?.openValue;

  frame()
    .kpop.dismiss({ animate, reason: "before-turbo-stream" })
    .then(() => {
      new StreamRenderer(frame(), this).render();
      frame().kpop.open(new StreamModal(this.target, this), { animate });
    });
};

export default class Kpop__FrameController extends Controller {
  static outlets = ["scrim"];
  static targets = ["modal"];
  static values = {
    open: Boolean,
  };

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

    this.opening ||= this.#nextAnimationFrame(() => {
      return this.#open(modal, { animate });
    });

    return this.opening;
  }

  async dismiss({ animate = true, reason = "" } = {}) {
    if (!this.isOpen) {
      this.debug("skip dismiss as already closed");
      return false;
    }

    this.dismissing ||= this.#nextAnimationFrame(() => {
      return new Promise((resolve) => {
        this.#dismiss({ animate, reason }).then(() => {
          return this.#nextAnimationFrame(resolve);
        });
      });
    });

    return this.dismissing;
  }

  // EVENTS

  popstate(event) {
    this.modal?.popstate(this, event);
  }

  beforeFrameRender(event) {
    this.debug("before-frame-render", event.detail.newFrame.baseURI);

    event.preventDefault();

    this.dismiss({ animate: true, reason: "before-frame-render" }).then(() => {
      event.detail.resume();
    });
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

    modal.open({ animate });
    scrim?.show({ animate });

    delete this.opening;

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

    this.debug("dismiss-end");
  }

  #nextAnimationFrame(callback) {
    return new Promise((resolve) => {
      window.requestAnimationFrame(() => {
        resolve(callback());
      });
    });
  }

  debug(event, ...args) {
    if (DEBUG) console.debug(`FrameController:${event}`, ...args);
  }
}
