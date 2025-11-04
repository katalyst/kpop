import { Turbo } from "@hotwired/turbo-rails";

import { StreamModal } from "../modals/stream_modal";

export default class StreamActions {
  start() {
    Turbo.StreamActions.kpop_open = openStreamModal;
  }

  stop() {
    delete Turbo.StreamActions.kpop_open;
  }
}

function openStreamModal() {
  const frame = this.targetElements[0]?.kpop;

  if (frame) {
    StreamModal.open(frame, this).then(() => {});
  }
}
