import FrameController from "../kpop/controllers/frame_controller";

import debug from "./utils/debug";
import LinkObserver from "./utils/link_observer";
import Ruleset from "./utils/ruleset";
import StreamActions from "./utils/stream_actions";

export const controllers = [
  { identifier: "kpop--frame", controllerConstructor: FrameController },
];

export default class Application {
  static configure(config = {}) {
    this.instance ||= new this(config);
    debug.enabled = this.instance.debug;
    return this.instance;
  }

  constructor({ rules = [], debug = false } = {}) {
    this.config = { rules, debug };
    this.ruleset = new Ruleset(rules);
    this.linkObserver = new LinkObserver(this, document);
    this.streamActions = new StreamActions();
  }

  start() {
    this.streamActions.start();
    this.linkObserver.start();

    window.addEventListener(
      "turbo:before-fetch-request",
      addKpopToRequestHeaders,
    );

    if (this.debug) {
      document.addEventListener("focusin", debugFocusIn);
      document.addEventListener("focusout", debugFocusOut);
    }

    return this;
  }

  stop() {
    window.removeEventListener(
      "turbo:before-fetch-request",
      addKpopToRequestHeaders,
    );
    document.removeEventListener("focusin", debugFocusIn);
    document.removeEventListener("focusout", debugFocusOut);

    this.streamActions.stop();
    this.linkObserver.stop();
  }

  isModalLink(link, location) {
    const properties = this.ruleset.properties(location);
    return properties.context === "modal";
  }

  get debug() {
    return Boolean(this.config.debug);
  }
}

const debugFocusIn = (e) => debug("Application")("focus", e.target);
const debugFocusOut = (e) => debug("Application")("blur", e.target);

const addKpopToRequestHeaders = (e) => {
  const headers = e.detail.fetchOptions.headers;

  if (headers["Accept"]?.includes("text/vnd.turbo-stream.html")) {
    headers["Kpop-Available"] = "true";
  }
};
