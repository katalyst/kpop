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
   * When the FrameController reloads the open modal's location, it runs this
   * method to open the new content in place, without animating.
   *
   * @param {Kpop__FrameController} frame
   * @param {HTMLDialogElement} dialog
   * @param {String} src
   */
  static reload(frame, dialog, src) {
    this.debug("reload", src);
    return frame.open(new FrameModal(frame, dialog, src), { animate: false });
  }
}
