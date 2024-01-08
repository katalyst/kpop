import { Turbo } from "@hotwired/turbo-rails";

import DEBUG from "./debug";

import { StreamModal } from "./modals/stream_modal";
import { StreamRenderer } from "./utils/stream_renderer";

function kpop(action) {
  return action.targetElements[0]?.kpop;
}

Turbo.StreamActions.kpop_open = function () {
  const animate = !kpop(this).openValue;

  kpop(this)
    ?.dismiss({ animate, reason: "before-turbo-stream" })
    .then(() => {
      new StreamRenderer(this.targetElements[0], this).render();
      kpop(this)?.open(new StreamModal(this.target, this), { animate });
    });
};

Turbo.StreamActions.kpop_dismiss = function () {
  kpop(this)?.dismiss({ reason: "turbo_stream.kpop.dismiss" });
};

Turbo.StreamActions.kpop_redirect_to = function () {
  if (this.dataset.turboFrame === this.target) {
    if (DEBUG)
      console.debug(
        `kpop: redirecting ${this.target} to ${this.getAttribute("href")}`,
      );
    const a = document.createElement("A");
    a.setAttribute("data-turbo-action", "replace");
    this.targetElements[0].delegate.navigateFrame(a, this.getAttribute("href"));
  } else {
    if (DEBUG)
      console.debug(`kpop: redirecting to ${this.getAttribute("href")}`);
    Turbo.visit(this.getAttribute("href"), {
      action: this.dataset.turboAction,
    });
  }
};
