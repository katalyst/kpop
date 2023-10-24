import { Turbo } from "@hotwired/turbo-rails";

import DEBUG from "../debug";

export class Modal {
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

  get currentLocationValue() {
    return this.modalElement?.dataset["kpop-ModalCurrentLocationValue"] || "/";
  }

  get fallbackLocationValue() {
    return this.modalElement?.dataset["kpop-ModalFallbackLocationValue"] || "/";
  }

  get layoutValue() {
    return this.modalElement?.dataset["kpop-ModalLayoutValue"] || "";
  }

  get isCurrentLocation() {
    return (
      window.history.state?.turbo && Turbo.session.location.href === this.src
    );
  }

  debug(event, ...args) {
    if (DEBUG) console.debug(`${this.constructor.name}:${event}`, ...args);
  }
}
