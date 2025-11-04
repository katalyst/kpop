import debug from "../utils/debug";

export class Modal {
  constructor(frame, dialog, src = null) {
    this.frame = frame;
    this.element = dialog;
    this.uri = new URL(src || dialog.dataset.src, window.location.origin);
  }

  connect() {
    this.element.addEventListener("cancel", this.cancel);
    this.element.addEventListener("close", this.close);
    this.element.addEventListener("mousedown", this.scrim);
  }

  disconnect() {
    this.element.removeEventListener("cancel", this.cancel);
    this.element.removeEventListener("close", this.close);
    this.element.removeEventListener("mousedown", this.scrim);
  }

  get src() {
    return this.uri.pathname + this.uri.search + this.uri.hash;
  }

  cancel = (e) => {
    this.debug("event:cancel", e);

    e.preventDefault();

    this.frame.dismiss({ animate: true, reason: "dialog:cancel" });
  };

  close = (e) => {
    this.debug("event:close", e);

    this.frame.clear({ reason: "dialog:close" });
  };

  scrim = (e) => {
    if (e.target.tagName === "DIALOG") {
      this.debug("event:scrim", e);

      this.frame.dismiss({ animate: true, reason: "dialog:scrim" });
    }
  };

  async open({ animate = true } = {}) {
    this.debug("open-start", animate);

    await animation(this.element, animate, () => this.element.showModal());

    this.debug("open-end");
  }

  /**
   * Modals are closed by animating out the modal then removing the modal
   * element from the wrapping frame.
   *
   * @returns {Promise<void>}
   */
  async dismiss({ animate = true } = {}) {
    this.debug("dismiss-start", animate);

    await animation(this.element, animate, () =>
      this.element.removeAttribute("open"),
    );

    this.debug("dismiss-end");

    this.element.close();
  }

  /**
   * When user navigates from inside a modal, dismiss the modal first so
   * that the modal does not appear in the history stack.
   *
   * @param frame FrameController
   * @param e Turbo navigation event
   */
  beforeVisit(frame, e) {
    this.debug(`before-visit`, e.detail.url);

    this.frame.clear();
  }

  static get debug() {
    return debug(this.name);
  }

  get debug() {
    return debug(this.constructor.name);
  }
}

function animation(el, animate, trigger) {
  if (!animate) return trigger();

  const duration = animationDuration(el);

  return new Promise((resolve) => {
    const resolver = () => {
      el.removeEventListener("animationend", resolver, { once: true });
      clearTimeout(timeout);
      el.toggleAttribute("animate", false);
      resolve();
    };

    el.addEventListener("animationend", resolver, { once: true });
    const timeout = setTimeout(resolver, duration);

    el.toggleAttribute("animate", animate);
    trigger();
  });
}

function animationDuration(el, defaultValue = "0.2s") {
  const value =
    getComputedStyle(el).getPropertyValue("--animation-duration") ||
    defaultValue;
  const num = parseFloat(value);
  if (value.endsWith("ms")) return num;
  return num * 1000;
}
