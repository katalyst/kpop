import { Controller } from "@hotwired/stimulus";

import DEBUG from "../debug";

export default class Kpop__ModalController extends Controller {
  static values = {
    fallback_location: String,
    layout: String,
  };

  connect() {
    this.debug("connect");

    if (this.layoutValue) {
      document.querySelector("#kpop").classList.toggle(this.layoutValue, true);
    }
  }

  disconnect() {
    this.debug("disconnect");

    if (this.layoutValue) {
      document.querySelector("#kpop").classList.toggle(this.layoutValue, false);
    }
  }

  debug(event, ...args) {
    if (DEBUG) console.debug(`ModalController:${event}`, ...args);
  }
}
