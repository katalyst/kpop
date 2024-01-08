import { Turbo } from "@hotwired/turbo-rails";

import { Modal } from "./modal";

export class ContentModal extends Modal {
  static connect(frame, element) {
    frame.open(new ContentModal(element.id), { animate: false });
  }

  constructor(id, src = null) {
    super(id);

    if (src) this.src = src;
  }

  /**
   * When the modal is dismissed we can't rely on a back navigation to close the
   * modal as the user may have navigated to a different location. Instead we
   * remove the content from the dom and replace the current history state with
   * the fallback location, if set.
   *
   * If there is no fallback location, we may be showing a stream modal that was
   * injected and cached by turbo. In this case, we clear the frame element and
   * do not change history.
   *
   * @returns {Promise<void>}
   */
  async dismiss() {
    const fallbackLocation = this.fallbackLocationValue;

    await super.dismiss();

    if (this.visitStarted) {
      this.debug("skipping dismiss, visit started");
      return;
    }
    if (!this.isCurrentLocation) {
      this.debug("skipping dismiss, not current location");
      return;
    }

    this.frameElement.innerHTML = "";

    if (fallbackLocation) {
      window.history.replaceState(window.history.state, "", fallbackLocation);
    }
  }

  beforeVisit(frame, e) {
    super.beforeVisit(frame, e);

    this.visitStarted = true;

    frame.scrimOutlet.hide({ animate: false });
  }

  get src() {
    return new URL(
      this.currentLocationValue.toString(),
      document.baseURI,
    ).toString();
  }
}
