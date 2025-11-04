# Upgrading to Kpop v4

Kpop v4 is a ground-up rewrite that standardizes how modals are rendered, opened, and dismissed across Rails, Turbo, and Stimulus. The release ships a new `<turbo-frame id="kpop">` component, richer server helpers, and a coordinated JavaScript runtime so history, focus, and navigation behave consistently on every platform (browser, Turbo Native, Turbo Streams).

## Core Architecture Changes

- **Frame component** &mdash; `Kpop::FrameComponent` now wraps modal content in a Turbo Frame that wires every Turbo lifecycle event (`before-fetch-request`, `before-frame-render`, `before-stream-render`, `before-visit`, `frame-load`) into the `kpop--frame` Stimulus controller so transitions can be animated and focus restored reliably.
- **Modal component contract** &mdash; All server-rendered modals use `Kpop::ModalComponent`, which emits a native `<dialog>` element with canonical header/close controls plus `data-src` metadata used to restore modals during restoration visits.
- **Layouts** &mdash; The gem ships `app/views/layouts/kpop/frame` and `kpop/stream` to ensure Turbo frame renders include the same `<head>` assets as the host app, avoiding the Turbo 8 caching issues that v3 users often hit.

## Server-Side Behavior

- **`expects_kpop` DSL** &mdash; Controllers can declare modal-aware actions (`expects_kpop(only: %i[new create]) { root_path }`). When those routes are visited without the kpop frame headers, requests are redirected (303) back to the fallback with `flash[:modal_location]` so the frame can be reopened automatically on page load.
- **Flash + redirects** &mdash; `FrameComponent` reads `flash[:modal_location]` and sets `src` on the frame so the Stimulus controller replays the modal without another user action. `resume_or_redirect_back_or_to` integrates with Turbo’s historical locations so close actions drop users in the right place.
- **Turbo Stream integration** &mdash; If requests arrive with `Kpop-Available: true` and request Turbo Streams, `FrameRequest#render` wraps responses in `turbo_stream.action(:kpop_open, "kpop", ...)`, letting the client swap dialogs via `StreamModal`.
- **Hotwire Native** &mdash; Overrides to `turbo_native_action_or_redirect` ensure Turbo Native apps can close modals via `turbo_resume_historical_location_path`, matching browser semantics.

## Client Runtime

- **Application bootstrap** &mdash; `Application.configure({ rules, debug })` now powers the JS side. Regex-based `rules` tell the `LinkObserver` which links should open in modals. When a link matches, it gets `data-turbo-frame="kpop"` so Turbo prefetches into the frame.
- **Header stamping** &mdash; The runtime listens for `turbo:before-fetch-request` to append `Kpop-Available: true` any time the request accepts Turbo Streams. Controllers can read this header to decide between redirect/stream behavior.
- **Stream action** &mdash; `StreamActions` registers `Turbo.StreamActions.kpop_open`, which loads template content into the frame, dismisses any existing modal, and animates the replacement.
- **Stimulus controller** &mdash; `frame_controller.js` intercepts Turbo frame renders, Turbo Streams, navigation, and `linkClickIntercepted` to debounce open/dismiss calls, manage focus, clear `busy` states, and detect mismatched layouts.

## UX Guarantees (Backed by System Specs)

- Opening modals via links, buttons, or page-load content always animates the dialog, updates the frame `src`, and moves focus into the modal.
- Closing via escape, close button, scrim click, stream action, or `kpop_button_close` returns focus to the previously active element and clears the frame `src`, so history stacks stay clean.
- Form submissions handle the four canonical flows: close, redirect to another page, render validation errors inside the existing modal, or swap to an entirely new modal.
- Navigation initiated inside a modal dismisses it before following the new URL, preventing stale dialogs from appearing in the back/forward history.
- Double-open race conditions are debounced: only the final navigation wins, and the frame ignores stale responses.

## Helper + Styling Updates

- Use `kpop_link_to` / `kpop_button_to` to guarantee `data-turbo-frame="kpop"` is set.
- Use `kpop_button_close` for accessible close buttons that call `kpop--frame#dismiss`.
- Base styles live in `app/assets/stylesheets/katalyst/kpop.css` and rely on CSS custom properties (`--animation-duration`, `--opening-animation`, etc.), making it easy to override themes without touching JS.

## Steps for Upgrading

1. **Install v4** &mdash; Update `katalyst-kpop` to a `4.x` release in your Gemfile and run `bundle install`.
2. **Adopt the new frame** &mdash; Render `Kpop::FrameComponent` (or include the provided `layouts/kpop/frame`) near the top of `application.html.erb` right after `<body>`.
3. **Initialize the JS runtime** &mdash; Import `@katalyst/kpop` in your Stimulus registry, call `Application.configure({ rules: [...] }).start()`, and define regex rules for every modal route.
4. **Annotate controllers** &mdash; Call `expects_kpop` in each controller that serves modals, supplying a fallback path and ensuring close/redirect actions use the patterns covered in v4 (streams for modals, redirects for pages).
5. **Update views** &mdash; Swap custom modal markup for `Kpop::ModalComponent` (or render the provided layout) so dialogs include the required header, close button, and `data-src`.
6. **Replace helpers** &mdash; Move to `kpop_link_to`, `kpop_button_to`, and `kpop_button_close` so all entry points set `data-turbo-frame="kpop"` and send the correct headers.
7. **Wire CSS + assets** &mdash; Ensure `@use "katalyst/kpop";` (or import the generated CSS) so the dialog/backdrop animations take effect; override CSS custom properties if you need bespoke theming.
8. **Verify behavior** &mdash; Run `bundle exec rake` (or at least `bundle exec rake spec system`) to confirm the new server and system specs pass in your app; pay special attention to closing flows and Turbo Stream fallbacks.
