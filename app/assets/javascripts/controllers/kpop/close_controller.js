import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class Kpop__CloseController extends Controller {
  static outlets = ["kpop--frame"];

  kpopFrameOutletConnected(frame) {
    frame.dismiss();
  }
}
