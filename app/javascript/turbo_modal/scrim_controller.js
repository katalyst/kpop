import { Controller } from "stimulus"

class ScrimController extends Controller {
  static targets = ["scrim"];

  show(event) {
    delete this.scrimTarget.dataset.hidden;
  }

  hide(event) {
    this.scrimTarget.dataset.hidden = "hidden";
    window.dispatchEvent(new Event("scrim-hide", { bubbles: true }))
  }
}

export default ScrimController;
