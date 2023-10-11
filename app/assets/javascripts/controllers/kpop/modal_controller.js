import { Controller } from "@hotwired/stimulus";

export default class Kpop__ModalController extends Controller {
  static values = {
    temporary: { type: Boolean, default: true },
  };

  connect() {
    // Set the modal content to temporary to ensure its omitted when caching the page
    this.element.toggleAttribute("data-turbo-temporary", this.temporaryValue);
  }
}
