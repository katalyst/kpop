import { Turbo } from "@hotwired/turbo-rails";

import { Modal } from "./modal";

export class StreamModal extends Modal {
  constructor(id, action) {
    super(id);

    this.action = action;
  }

  /**
   * When the modal opens, push a state event for the current location so that
   * the user can dismiss the modal by navigating back.
   *
   * @returns {Promise<void>}
   */
  async open() {
    await super.open();

    window.history.pushState({ kpop: true, id: this.id }, "", window.location);
  }

  /**
   * On dismiss, pop the state event that was pushed when the modal opened,
   * then clear any modals from the turbo frame element.
   *
   * @returns {Promise<void>}
   */
  async dismiss() {
    await super.dismiss();

    if (this.isCurrentLocation) {
      await this.pop("popstate", () => window.history.back());
    }

    this.frameElement.innerHTML = "";
  }

  /**
   * On navigation from inside the modal, dismiss the modal first so that the
   * modal does not appear in the history stack.
   *
   * @param frame TurboFrame element
   * @param e Turbo navigation event
   */
  beforeVisit(frame, e) {
    super.beforeVisit(frame, e);

    e.preventDefault();

    frame.dismiss({ animate: false }).then(() => {
      Turbo.visit(e.detail.url);

      this.debug("before-visit-end");
    });
  }

  /**
   * If the user pops state, dismiss the modal.
   *
   * @param frame FrameController
   * @param e history event
   */
  popstate(frame, e) {
    super.popstate(frame, e);

    frame.dismiss({ animate: true, reason: "popstate" });
  }

  get isCurrentLocation() {
    return window.history.state?.kpop && window.history.state?.id === this.id;
  }
}
