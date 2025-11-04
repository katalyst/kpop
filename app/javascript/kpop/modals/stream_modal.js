import { Modal } from "./modal";

export class StreamModal extends Modal {
  /**
   * When a turbo-stream[action=kpop_open] element is rendered, it runs this
   * method to load the modal template as a StreamModal.
   *
   * @param {Kpop__FrameController} frame
   * @param {Turbo.StreamElement} action
   */
  static async open(frame, action) {
    const animate = !frame.isOpen;

    await frame.dismiss({ animate, reason: "turbo-stream.kpop_open" });

    frame.element.append(action.templateContent);

    const dialog = frame.element.querySelector("dialog");
    const src = dialog.dataset.src;

    await frame.open(new StreamModal(frame, dialog, src), { animate });
  }
}
