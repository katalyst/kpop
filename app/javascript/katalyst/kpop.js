import CloseController from "../kpop/controllers/close_controller";
import FrameController from "../kpop/controllers/frame_controller";
import ModalController from "../kpop/controllers/modal_controller";
import RedirectController from "../kpop/controllers/redirect_controller";
import ScrimController from "../kpop/controllers/scrim_controller";

const Definitions = [
  { identifier: "kpop--close", controllerConstructor: CloseController },
  { identifier: "kpop--frame", controllerConstructor: FrameController },
  { identifier: "kpop--modal", controllerConstructor: ModalController },
  { identifier: "kpop--redirect", controllerConstructor: RedirectController },
  { identifier: "scrim", controllerConstructor: ScrimController },
];

export { Definitions as default };
