import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

const DEBUG = false;

class Modal {
  constructor(id) {
    this.id = id;
  }

  async open() {
    this.debug("open");
  }

  async dismiss() {
    this.debug(`dismiss`);
  }

  beforeVisit(frame, e) {
    this.debug(`before-visit`, e.detail.url);
  }

  async pop(event, callback) {
    this.debug(`pop`);

    const promise = new Promise((resolve) => {
      window.addEventListener(
        event,
        () => {
          resolve();
        },
        { once: true }
      );
    });

    callback();

    return promise;
  }

  get frameElement() {
    return document.getElementById(this.id);
  }

  get modalElement() {
    return this.frameElement?.querySelector("[data-controller*='kpop--modal']");
  }

  get fallbackLocationValue() {
    return this.modalElement?.dataset["kpop-ModalFallbackLocationValue"] || "/";
  }

  get layoutValue() {
    return this.modalElement?.dataset["kpop-ModalLayoutValue"];
  }

  get isCurrentLocation() {
    return window.history.state?.turbo && Turbo.session.location.href === this.src;
  }

  debug(event, ...args) {
    if (DEBUG) console.debug(`${this.constructor.name}:${event}`, ...args);
  }
}

class StreamModal extends Modal {
  constructor(id, action) {
    super(id);

    this.action = action;
  }

  async open() {
    await super.open();

    window.history.pushState({ kpop: true, id: this.id }, "", window.location);
  }

  async dismiss() {
    await super.dismiss();

    if (this.isCurrentLocation) {
      await this.pop("popstate", () => window.history.back());
    }

    this.frameElement.innerHTML = "";
  }

  beforeVisit(frame, e) {
    super.beforeVisit(frame, e);

    e.preventDefault();

    frame.dismiss({ animate: false }).then(() => {
      Turbo.visit(e.detail.url);

      this.debug("before-visit-end");
    });
  }

  get isCurrentLocation() {
    return window.history.state?.kpop && window.history.state?.id === this.id;
  }
}

class FrameModal extends Modal {
  constructor(id, src) {
    super(id);
    this.src = src;
  }

  async dismiss() {
    await super.dismiss();

    if (!this.isCurrentLocation) {
      this.debug("skipping dismiss, not current location");
    }


    await this.pop("turbo:load", () => window.history.back());

    // no specific close action required, this is turbo's responsibility
  }

  beforeVisit(frame, e) {
    super.beforeVisit(frame, e);

    e.preventDefault();

    frame.dismiss({ animate: false }).then(() => {
      Turbo.visit(e.detail.url);

      this.debug("before-visit-end");
    });
  }
}

class ContentModal extends Modal {
  constructor(id, src = Turbo.session.location.href) {
    super(id);

    this.src = src;
  }

  async dismiss() {
    await super.dismiss();

    if (this.visitStarted) {
      this.debug("skipping dismiss, visit started");
      return;
    }
    if (!this.isCurrentLocation) {
      this.debug("skipping dismiss, not current location");
      return;
    }

    return this.pop("turbo:load", () => {
      this.debug("turbo-visit", this.fallbackLocationValue)
      Turbo.visit(this.fallbackLocationValue, { action: "replace" });
    });

    // no specific close action required, this is turbo's responsibility
  }

  beforeVisit(frame, e) {
    super.beforeVisit(frame, e);

    this.visitStarted = true;

    frame.scrimOutlet.hide({ animate: false });
  }
}

class StreamRenderer {
  constructor(frame, action) {
    this.frame = frame;
    this.action = action;
  }

  render() {
    if (DEBUG) console.debug("stream-renderer:render");
    this.frame.src = "";
    this.frame.innerHTML = "";
    this.frame.append(this.action.templateContent);
  }
}

Turbo.StreamActions.kpop_open = function() {
  const frame = () => { return this.targetElements[0] };
  const animate = !frame?.kpop?.openValue;

  frame().kpop.dismiss({ animate, reason: "before-turbo-stream" }).then(() => {
    new StreamRenderer(frame(), this).render();
    frame().kpop.open(new StreamModal(this.target, this), { animate });
  });
};

export default class Kpop__FrameController extends Controller {
  static outlets = ["scrim"];
  static targets = ["modal"];
  static values = {
    open: Boolean
  };

  connect() {
    this.debug("connect", this.element.src);

    this.element.kpop = this;

    // restoration visit
    if (this.element.src && this.element.complete) {
      this.debug("new frame modal", this.element.src);
      this.open(new FrameModal(this.element.id, this.element.src), { animate: false });
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
    this.debug("open-changed");

    this.element.parentElement.style.display = open ? "flex" : "none";
  }

  async open(modal, { animate = true } = {}) {
    if (this.isOpen) {
      this.debug("skip open as already open")
      return false;
    }

    this.opening ||= this.#nextAnimationFrame(() => {
      return this.#open(modal, { animate });
    });

    return this.opening;
  }

  async dismiss({ animate = true, reason = "" } = {}) {
    if (!this.isOpen) {
      this.debug("skip dismiss as already closed")
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
    this.dismiss({ animate: false, reason: "popstate" });
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

    return this.open(new FrameModal(this.element.id, this.element.src), { animate: true });
  }

  get isOpen() {
    return this.openValue && !this.dismissing;
  }

  async #open(modal, { animate = true } = {}) {
    this.debug("open-start", { animate });

    const scrim = this.scrimConnected && this.scrimOutlet;

    this.modal = modal;
    this.openValue = true;
    this.element.classList.add(modal.layoutValue);

    modal.open({ animate });
    scrim?.show({ animate });

    delete this.opening;

    this.debug("open-end");
  }

  async #dismiss({ animate = true, reason = "" } = {}) {
    this.debug("dismiss-start", { animate, reason });

    await this.scrimOutlet.hide({ animate });
    await this.modal.dismiss();

    this.element.classList.remove(this.modal?.layoutValue);
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
