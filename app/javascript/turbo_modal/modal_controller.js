import { Controller } from "stimulus";
import { hideScrim, showScrim } from "./scrim_controller";

/**
 * Shows a Turbo modal when triggered by a `modal_link` click or a call to `openModal`.
 */
class ModalController extends Controller {
  static targets = ["turboFrame"];

  static values = {
    type: String
  }

  typeValueChanged(value) {
    if (value === "") return;
    this.turboFrameTarget.classList.add(value);
  }

  open(e) {
    this.turboFrameTarget.src = e.detail.url;
    this.typeValue = e.detail.type;
    showScrim();
  }

  close(e) {
    if (this.turboFrameTarget.src === null) return;

    const modal_element = this.turboFrameTarget.querySelector(".modal")
    modal_element.classList.remove("animate-in");
    modal_element.classList.add("animate-out");
    setTimeout(() => {
      modal_element.remove();
      this.turboFrameTarget.src = null;

      if (this.typeValue !== "") {
        this.turboFrameTarget.classList.remove(this.typeValue);
        this.typeValue = "";
      }
      hideScrim();
    }, 250);
  }

  keyup(event) {
    if (event.key === "Escape") {
      closeModal();
    }
  }

  onLinkClick(e) {
    const modal_link = e.target.closest("a[data-modal-type]")
    openModal(modal_link.href, modal_link.dataset.modalType);
  }
}

/**
 * Show a modal, requires a url for a page that renders a turbo-frame with id `modal`.
 */
function openModal(url, type = "") {
  window.dispatchEvent(new CustomEvent("modal:open", { detail: { url: url, type: type }}));
}

/**
 * Hide the current modal (if any).
 */
function closeModal() {
  window.dispatchEvent(new Event("modal:close"));
}

export { ModalController as default, openModal, closeModal }
