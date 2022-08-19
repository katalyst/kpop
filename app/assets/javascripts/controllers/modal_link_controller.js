import { Controller } from "@hotwired/stimulus";
import { openModal } from "./modal_controller";

/**
 * Shows a Turbo modal when clicked.
 */
export default class ModalLinkController extends Controller {
  onClick(e) {
    e.preventDefault();
    openModal(this.element.href, this.element.dataset.modalType);
  }
}
