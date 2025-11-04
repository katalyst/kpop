/**
 * Based on Turbo's LinkObserver, checks links on mouse-over and focus to see
 * whether they should open in modals. If they should, then sets the
 * data-turbo-frame attribute so it will be prefetched and opened in the context
 * of the kpop turbo frame.
 */
export default class LinkObserver {
  started = false;

  constructor(delegate, eventTarget) {
    this.delegate = delegate;
    this.eventTarget = eventTarget;
  }

  start() {
    if (this.started) return;
    if (this.eventTarget.readyState === "loading") {
      this.eventTarget.addEventListener("DOMContentLoaded", this.#enable, {
        once: true,
      });
    } else {
      this.#enable();
    }
  }

  stop() {
    if (!this.started) return;
    this.eventTarget.removeEventListener("mouseenter", this.#addKpopLink, {
      capture: true,
      passive: true,
    });
    this.eventTarget.removeEventListener(
      "turbo:before-prefetch",
      this.#addKpopLink,
      {
        capture: true,
        passive: true,
      },
    );
    this.eventTarget.removeEventListener("focusin", this.#addKpopLink, {
      capture: true,
      passive: true,
    });
    this.eventTarget.removeEventListener("mouseleave", this.#removeKpopLink, {
      capture: true,
      passive: true,
    });
    this.eventTarget.removeEventListener("focusout", this.#removeKpopLink, {
      capture: true,
      passive: true,
    });
    this.started = false;
  }

  #enable = () => {
    if (this.started) return;
    this.started = true;
    this.eventTarget.addEventListener("mouseenter", this.#addKpopLink, {
      capture: true,
      passive: true,
    });
    this.eventTarget.addEventListener("focusin", this.#addKpopLink, {
      capture: true,
      passive: true,
    });
    this.eventTarget.addEventListener(
      "turbo:before-prefetch",
      this.#addKpopLink,
      {
        capture: true,
        passive: true,
      },
    );
    this.eventTarget.addEventListener("mouseleave", this.#removeKpopLink, {
      capture: true,
      passive: true,
    });
    this.eventTarget.addEventListener("focusout", this.#removeKpopLink, {
      capture: true,
      passive: true,
    });
  };

  #addKpopLink = (event) => {
    const target = event.target;
    const isLink =
      target.matches &&
      target.matches(
        "a[href]:not([target^=_]):not([download]):not([data-turbo-frame]",
      );
    if (isLink && this.#isPrefetchable(target)) {
      const link = target;
      const location = getLocationForLink(link);
      if (this.delegate.isModalLink(link, location)) {
        link.dataset.turboFrame = "kpop";
      }
    }
  };

  #removeKpopLink = (event) => {
    const target = event.target;
    const isLink =
      target.matches && target.matches("a[href][data-turbo-frame='kpop']");
    if (isLink) {
      delete target.dataset.turboFrame;
    }
  };

  #isPrefetchable(link) {
    const href = link.getAttribute("href");
    if (!href) return false;
    if (unfetchableLink(link)) return false;
    if (linkToTheSamePage(link)) return false;
    if (linkOptsOut(link)) return false;
    if (nonSafeLink(link)) return false;
    return true;
  }
}

function getLocationForLink(link) {
  return new URL(link.getAttribute("href").toString(), document.baseURI);
}

const unfetchableLink = (link) =>
  link.origin !== document.location.origin ||
  !["http:", "https:"].includes(link.protocol) ||
  link.hasAttribute("target");

const linkToTheSamePage = (link) =>
  link.pathname + link.search ===
    document.location.pathname + document.location.search ||
  link.href.startsWith("#");

const linkOptsOut = (link) => {
  return link.getAttribute("data-turbo") === "false";
};

const nonSafeLink = (link) => {
  const turboMethod = link.getAttribute("data-turbo-method");
  if (turboMethod && turboMethod.toLowerCase() !== "get") return true;
  if (isUJS(link)) return true;
  if (link.hasAttribute("data-turbo-confirm")) return true;
  if (link.hasAttribute("data-turbo-stream")) return true;
  return false;
};

const isUJS = (link) =>
  link.hasAttribute("data-remote") ||
  link.hasAttribute("data-behavior") ||
  link.hasAttribute("data-confirm") ||
  link.hasAttribute("data-method");
