import { Turbo } from "@hotwired/turbo-rails";

/**
 * Routes Turbo visits to locations that match a modal rule into the kpop
 * frame, the way Hotwire Native routes visits with its path configuration.
 * Callers use `Turbo.visit` and the ruleset decides how the location shows.
 *
 * Wraps Turbo's browser adapter, which Turbo does not export, so every other
 * adapter call reaches the browser adapter unchanged.
 */
export default class VisitAdapter {
  started = false;

  constructor(delegate) {
    this.delegate = delegate;
  }

  start() {
    if (this.started) return;

    const adapter = (this.adapter = Turbo.session.adapter);
    const visitAdapter = this;

    Turbo.registerAdapter(
      Object.assign(Object.create(adapter), {
        visitProposedToLocation(location, options) {
          if (visitAdapter.#shouldVisitInFrame(location, options)) {
            Turbo.visit(location, { frame: "kpop" });
          } else {
            adapter.visitProposedToLocation(location, options);
          }
        },
      }),
    );

    this.started = true;
  }

  stop() {
    if (!this.started) return;

    Turbo.registerAdapter(this.adapter);
    delete this.adapter;

    this.started = false;
  }

  /**
   * Like Hotwire Native, the rules decide how a location shows, whatever the
   * link that proposed it says, so `data-turbo-frame="_top"` does not opt out.
   * Use a rule override or `data-turbo="false"` instead. Turbo submits
   * `data-turbo-stream` links as forms, so they never reach the adapter.
   */
  #shouldVisitInFrame(location, options) {
    // A response means Turbo has already fetched the page, e.g. after a form
    // submission or a redirect, so let it render.
    if (options?.response) return false;

    // Refreshes and visits to the current page should not open a modal.
    if (isCurrentPage(location)) return false;

    // Without a frame, Turbo.visit would propose this visit again.
    if (!(document.getElementById("kpop") instanceof Turbo.FrameElement)) {
      return false;
    }

    return this.delegate.isModalLocation(location);
  }
}

function isCurrentPage(location) {
  return (
    location.pathname + location.search ===
    document.location.pathname + document.location.search
  );
}
