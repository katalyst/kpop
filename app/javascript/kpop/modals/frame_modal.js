import { Turbo } from "@hotwired/turbo-rails";

import { Modal } from "./modal";

export class FrameModal extends Modal {
  constructor(id, src) {
    super(id);
    this.src = src;
  }

  async dismiss() {
    await super.dismiss();

    if (!this.isCurrentLocation) {
      this.debug("skipping dismiss, not current location");
    } else {
      await this.pop("turbo:load", () => window.history.back());
    }

    // no specific close action required, this is turbo's responsibility
  }

  beforeVisit(frame, e) {
    super.beforeVisit(frame, e);

    e.preventDefault();

    frame.dismiss({ animate: false }).then(() => {
      Turbo.visit(e.detail.url);

      this.debug("before-visit-end");
    });
  }

  popstate(frame, e) {
    super.popstate(frame, e);

    // Turbo will restore modal state, but we need to reset the scrim
    frame.scrimOutlet.hide({ animate: false });
  }
}
