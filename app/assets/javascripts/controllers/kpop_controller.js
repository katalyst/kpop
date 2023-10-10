import { Controller } from "@hotwired/stimulus";

export default class KpopController extends Controller {
  static outlets = ["scrim"];
  static targets = ["content"];
  static values = {
    open: Boolean,
  };

  scrimOutletConnected(scrim) {
    // return if already initialized
    if (this.openValue) return;

    // Capture the scrim and then show the content
    if (this.hasContentTarget) {
      scrim.show().then(() => (this.openValue = true));
    }
  }

  contentTargetConnected(content) {
    // Set the modal content to temporary to ensure its omitted when caching the page
    content.setAttribute("data-turbo-temporary", "");

    // When switching modals a target may connect while scrim is already open
    if (this.openValue) return;

    // Capture the scrim and then show the content if the scrim is ready
    if (this.hasScrimOutlet) {
      this.scrimOutlet.show().then(() => (this.openValue = true));
    }
  }

  contentTargetDisconnected() {
    // When switching modals there may still be content to show
    if (this.hasContentTarget) return;

    this.openValue = false;
    if (this.hasScrimOutlet) {
      this.scrimOutlet.hide();
    }
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
