import { Controller } from "@hotwired/stimulus";
import ScrimController from "./scrim_controller";

export default class KpopController extends Controller {
  static targets = ["content", "closeButton"];
  static values = {
    open: Boolean,
  };

  contentTargetConnected() {
    // When switching modals a target may connect while scrim is already open
    if (this.openValue) return;

    if (ScrimController.showScrim({ dismiss: this.hasCloseButtonTarget })) {
      this.openValue = true;
    } else {
      this.#clear();
    }
  }

  contentTargetDisconnected() {
    // When switching modals there may still be content to show
    if (this.hasContentTarget) return;

    this.openValue = false;
    ScrimController.hideScrim();
  }

  openValueChanged(open) {
    this.element.style.display = open ? "flex" : "none";
  }

  dismiss() {
    if (!this.hasContentTarget || !this.openValue) return;

    const dismissUrl = this.contentTarget.dataset.dismissUrl;
    const dismissAction = this.contentTarget.dataset.dismissAction;

    if (dismissUrl) {
      if (dismissAction === "replace") {
        if (isSameUrl(document.referrer, dismissUrl)) {
          // if we came from the same page, send the user back
          history.back();
        } else {
          // if we came from a different page, dismiss the modal and replace url
          history.replaceState({}, "", dismissUrl);
        }
      } else {
        // default, send the user on to the specified URL
        window.location.href = dismissUrl;
      }
    }

    this.#clear();
  }

  #clear() {
    this.element.removeAttribute("src");
    this.element.innerHTML = "";
  }
}

function isSameUrl(previous, next) {
  try {
    return `${new URL(previous)}` === `${new URL(next, location.href)}`;
  } catch {
    return false;
  }
}
