import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class Kpop__RedirectController extends Controller {
  static outlets = ["kpop--frame"];
  static values = {
    path: String,
    target: String,
  };

  kpopFrameOutletConnected(frame) {
    if (this.targetValue === frame.element.id) {
      frame.dismiss().then(() => {
        document.getElementById(this.targetValue).src = this.pathValue;
      });
    } else {
      Turbo.visit(this.pathValue, { action: "replace" });
    }

    this.element.remove();
  }
}
