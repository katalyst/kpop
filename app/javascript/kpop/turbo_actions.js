import { Turbo } from "@hotwired/turbo-rails";

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
    this.targetElements[0].src = this.getAttribute("href");
  } else {
    Turbo.visit(this.getAttribute("href"), {
      action: this.dataset.turboAction,
    });
  }
};
