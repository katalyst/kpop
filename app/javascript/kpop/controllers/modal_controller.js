import { Controller } from "@hotwired/stimulus";

import DEBUG from "../debug";

export default class Kpop__ModalController extends Controller {
  static values = {
    fallback_location: String,
  };

  connect() {
    this.debug("connect");
  }

  disconnect() {
    this.debug("disconnect");
  }

  debug(event, ...args) {
    if (DEBUG) console.debug(`ModalController:${event}`, ...args);
  }
}
