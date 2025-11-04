import { Modal } from "./modal";

export class ContentModal extends Modal {
  static connect(frame, dialog) {
    frame.open(new ContentModal(frame, dialog), { animate: false });
  }
}
