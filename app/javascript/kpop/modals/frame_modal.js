import { Turbo } from "@hotwired/turbo-rails";

import { Modal } from "./modal";

export class FrameModal extends Modal {
  /**
   * When the FrameController detects a frame element on connect, it runs this
   * method to sanity check the frame src and restore the modal state.
   *
   * @param frame FrameController
   * @param element TurboFrame element
   */
  static connect(frame, element) {
    const modal = new FrameModal(element.id, element.src);

    // state reconciliation for turbo restore of invalid frames
    if (modal.isCurrentLocation) {
      // restoration visit
      this.debug("restore", element.src);
      return frame.open(modal, { animate: false });
    } else {
      console.warn(
        "kpop: restored frame src doesn't match window href",
        modal.src,
        window.location.href,
      );
      return frame.clear();
    }
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

    if (element.src === location) {
      this.debug("skipping navigate as already on location");
      return;
    }

    if (element.src && element.src !== window.location.href) {
      console.warn(
        "kpop: frame src doesn't match window",
        element.src,
        window.location.href,
        location,
      );
      frame.clear();
    }

    this.debug("navigate to", location);
    resolve();
  }

  constructor(id, src) {
    super(id);
    this.src = src;
  }

  /**
   * FrameModals are closed by running pop state and awaiting the turbo:load
   * event that follows on history restoration.
   *
   * @returns {Promise<void>}
   */
  async dismiss() {
    await super.dismiss();

    if (!this.isCurrentLocation) {
      this.debug("skipping dismiss, not current location");
    } else {
      await this.pop("turbo:load", () => window.history.back());
    }

    // no specific close action required, this is turbo's responsibility
  }

  /**
   * When user navigates from inside a Frame modal, dismiss the modal first so
   * that the modal does not appear in the history stack.
   *
   * @param frame FrameController
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
}
