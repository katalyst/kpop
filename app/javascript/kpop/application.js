import FrameController from "../kpop/controllers/frame_controller";
import ModalController from "../kpop/controllers/modal_controller";
import ScrimController from "../kpop/controllers/scrim_controller";

import "./turbo_actions";

const Definitions = [
  { identifier: "kpop--frame", controllerConstructor: FrameController },
  { identifier: "kpop--modal", controllerConstructor: ModalController },
  { identifier: "scrim", controllerConstructor: ScrimController },
];

export { Definitions as default };
