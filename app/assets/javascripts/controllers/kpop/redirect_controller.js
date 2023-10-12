import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo";

export default class Kpop__RedirectController extends Controller {
  static values = {
    path: String,
  };

  connect() {
    Turbo.visit(this.pathValue);

    this.element.remove();
  }
}
