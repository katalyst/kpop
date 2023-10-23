import { Turbo } from "@hotwired/turbo-rails";

import { Modal } from "./modal";

export class StreamModal extends Modal {
  constructor(id, action) {
    super(id);

    this.action = action;
  }

  async open() {
    await super.open();

    window.history.pushState({ kpop: true, id: this.id }, "", window.location);
  }

  async dismiss() {
    await super.dismiss();

    if (this.isCurrentLocation) {
      await this.pop("popstate", () => window.history.back());
    }

    this.frameElement.innerHTML = "";
  }

  beforeVisit(frame, e) {
    super.beforeVisit(frame, e);

    e.preventDefault();

    frame.dismiss({ animate: false }).then(() => {
      Turbo.visit(e.detail.url);

      this.debug("before-visit-end");
    });
  }

  get isCurrentLocation() {
    return window.history.state?.kpop && window.history.state?.id === this.id;
  }
}
