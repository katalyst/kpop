import { Turbo } from "@hotwired/turbo-rails";

import { Modal } from "./modal";

export class ContentModal extends Modal {
  constructor(id, src = null) {
    super(id);

    if (src) this.src = src;
  }

  async dismiss() {
    await super.dismiss();

    if (this.visitStarted) {
      this.debug("skipping dismiss, visit started");
      return;
    }
    if (!this.isCurrentLocation) {
      this.debug("skipping dismiss, not current location");
      return;
    }

    return this.pop("turbo:load", () => {
      this.debug("turbo-visit", this.fallbackLocationValue);
      Turbo.visit(this.fallbackLocationValue, { action: "replace" });
    });

    // no specific close action required, this is turbo's responsibility
  }

  beforeVisit(frame, e) {
    super.beforeVisit(frame, e);

    this.visitStarted = true;

    frame.scrimOutlet.hide({ animate: false });
  }

  get src() {
    return new URL(
      this.currentLocationValue.toString(),
      document.baseURI
    ).toString();
  }
}
