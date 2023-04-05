import KpopController from "../controllers/kpop_controller";
import ScrimController from "../controllers/scrim_controller";

const Definitions = [
  { identifier: "kpop", controllerConstructor: KpopController },
  { identifier: "scrim", controllerConstructor: ScrimController },
];

export { Definitions as default, KpopController, ScrimController };
