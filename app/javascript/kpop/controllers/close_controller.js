import { Controller } from "@hotwired/stimulus";

export default class Kpop__CloseController extends Controller {
  static outlets = ["kpop--frame"];

  kpopFrameOutletConnected(frame) {
    frame.dismiss();
  }
}
