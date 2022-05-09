# 0.3.2

 * Allow modals to be non-dismissable

# 0.3.1

 * Added `modal-link` controller – supports modal links without requiring a global controller.
 * Add definitions export for easier controller registration:
    ```js
    import TurboModal from "@katalyst-interactive/turbo-modal"
    application.load(TurboModal)
    ```
 * Bug fixes
   * Clipping issue on short devices
   * Prevent scrolling background content while modal is present

# 0.2.0

 * Body data attributes are no longer required, these are now provided by the helpers instead.
 * Event names have changed: `show-scrim` is now `scrim:show`, `hide-scrim` and `scrim-hide` are now `scrim:hide`.
 * Programmatic methods exported for show/hide of both modal and scrim.
 * Dependencies have been relaxed to support Rails 7 and `turbo-rails` releases.
 * Change modal breakpoints to use explicit values
