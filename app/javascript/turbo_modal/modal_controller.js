import { Controller } from "stimulus";

export default class ModalController extends Controller {
  static targets = ["turboFrame"];

  static values = {
    type: String
  }

  typeValueChanged(value) {
    if (value === "") return;
    this.turboFrameTarget.classList.add(value);
  }

  close() {
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
      window.dispatchEvent(new Event("hide-scrim", { bubbles: true }))
    }, 250);
  }

  keyup(event) {
    if (event.key === 'Escape') this.close();
  }

  showModal(e) {
    const modal_link = e.target.closest("a[data-modal-type]")
    this.typeValue = modal_link.dataset.modalType
    window.dispatchEvent(new Event("show-scrim", { bubbles: true }))
  }
}
