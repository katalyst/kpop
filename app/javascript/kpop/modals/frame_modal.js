import { Modal } from "./modal";

export class FrameModal extends Modal {
  /**
   * When the FrameController detects a frame element on connect, it runs this
   * method to sanity check the frame src and restore the modal state.
   *
   * @param {Kpop__FrameController} frame
   * @param {HTMLDialogElement} dialog
   * @param {String} src
   */
  static connect(frame, dialog, src) {
    // restoration visit
    this.debug("restore", src);
    return frame.open(new FrameModal(frame, dialog, src), { animate: false });
  }

  /**
   * When the FrameController detects a frame load event, it runs this
   * method to open the modal.
   *
   * @param {Kpop__FrameController} frame
   * @param {HTMLDialogElement} dialog
   * @param {String} src
   */
  static load(frame, dialog, src) {
    this.debug("load", src);
    return frame.open(new FrameModal(frame, dialog, src), { animate: true });
  }

  /**
   * When a user clicks a kpop link, turbo intercepts the click and calls
   * #navigateFrame on the turbo frame controller before setting the TurboFrame
   * element's src attribute. KPOP intercepts this call and calls this method
   * first so we cancel problematic navigations that might cache invalid states.
   *
   * @param location URL requested by turbo
   * @param frame FrameController
   * @param element TurboFrame element
   * @param resolve continuation chain
   */
  static visit(location, frame, element, resolve) {
    // Ensure that turbo doesn't cache the frame in a loading state by cancelling
    // the current request (if any) by clearing the src.
    // Known issue: this won't work if the frame was previously rendering a useful src.
    if (element.hasAttribute("busy")) {
      this.debug("clearing src to cancel turbo request");
      element.src = "";
    }

    this.debug("navigate to", location);
    resolve();
  }
}
