import ModalController, { openModal, closeModal } from "./modal_controller";
import ModalLinkController from "./modal_link_controller";
import ScrimController, { showScrim, hideScrim } from "./scrim_controller";

const Definitions = [
  { identifier: "modal", controllerConstructor: ModalController },
  { identifier: "modal-link", controllerConstructor: ModalLinkController },
  { identifier: "scrim", controllerConstructor: ScrimController }
];

export {
  Definitions as default,
  ModalController, openModal, closeModal,
  ScrimController, showScrim, hideScrim,
  ModalLinkController
};
