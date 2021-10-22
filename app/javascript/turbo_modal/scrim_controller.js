import { Controller } from "stimulus"

class ScrimController extends Controller {
  static targets = ["scrim"];

  toggle(event) {
    event.preventDefault();

    const hide = this.scrimTarget.toggleAttribute("hidden");
  }

  show(event) {
    const hide = this.scrimTarget.removeAttribute("hidden");
  }

  hide(event) {
    this.scrimTarget.setAttribute("hidden", "hidden");
    window.dispatchEvent(new Event("scrim-hide", { bubbles: true }))
  }
}

export default ScrimController;
