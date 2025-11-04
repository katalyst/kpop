# kpop

Kpop delivers Turbo-powered modals for Rails applications. Version 4 rebuilds the integration so Turbo frames, Turbo Streams, Stimulus, and Turbo Native all share the same life cycle: focus is restored, history stays clean, and dialogs can reopen automatically after redirects. See `doc/upgrading-to-v4.md` if you are migrating from an earlier release.

## Installation

### 1. Gem

```bash
# Gemfile
bundle add "katalyst-kpop"
```

### 2. JavaScript package (Importmap)

```ruby
# config/importmap.rb
pin "@katalyst/kpop", to: "katalyst/kpop.js", preload: true
```

## Stimulus setup

Register the provided controllers so `<turbo-frame id="kpop">` elements receive the `kpop--frame` behaviour.

```js
// app/javascript/controllers/index.js
import { application } from "./application";
import { controllers as kpop } from "@katalyst/kpop";

application.load(kpop);
```

## Bootstrap the runtime

The package exports a client runtime that observes links, stamps the `Kpop-Available` header on Turbo fetches, and exposes a `kpop_open` Turbo Stream action. Configure it once during boot:

```js
// app/javascript/application.js
import "@hotwired/turbo-rails";
import kpop from "@katalyst/kpop";

kpop
  .configure({
    rules: [
      {
        patterns: ["^/modal"],
        properties: { context: "modal" },
      },
    ],
    debug: false,
  })
  .start();
```

Rules are regex strings matched against `location.pathname`. When `properties.context === "modal"`, the runtime sets `data-turbo-frame="kpop"` on hovered/focused links so Turbo prefetches them into the modal frame.

## Render the frame

Every layout that can host a modal needs the frame near the end of `<body>`:

```erb
<!-- app/views/layouts/application.html.erb -->
<body>
  <%= yield %>
  <%= render Kpop::FrameComponent.new do %>
    <%= yield :kpop %>
  <% end %>
</body>
```

`Kpop::FrameComponent` wires all Turbo life-cycle events into the Stimulus controller and automatically replays `flash[:modal_location]`. Use `content_for :kpop` only when you want to inject a modal during an ordinary page load.

## Controller integration

Include the concern by calling `expects_kpop` in controllers that serve modals:

```ruby
class InvitationsController < ApplicationController
  expects_kpop(only: %i[new create]) { root_path }

  def new
    render layout: "kpop/frame"
  end

  def create
    if invitation.save
      redirect_to(invitation_path(invitation), status: :see_other)
    else
      render :new, status: :unprocessable_content
    end
  end
end
```

When the JS runtime sets `Kpop-Available: true`, `expects_kpop` will:

- Redirect full-page GET requests back with `flash[:modal_location]` so the modal reopens automatically.
- Wrap Turbo Stream renders in `turbo_stream.action(:kpop_open, "kpop", ...)`, letting the client swap dialogs without navigating.
- Override Turbo Native redirects so closing a modal can resume the historical location.

## Triggering modals

Use the helpers so links and forms always target the frame:

```erb
<%= kpop_link_to "Invite a user", new_invitation_path %>
<%= kpop_button_to "Launch dialog", new_invitation_path %>
<%= kpop_button_close "Close" %>
```

Inside the modal view render the provided component, which outputs a native `<dialog>` with the data attributes the Stimulus controller relies on:

```erb
<%= render Kpop::ModalComponent.new(title: "Invite a user", modal_class: :invite) do %>
  <%= render "form", invitation: @invitation %>
<% end %>
```

## Styling

Import the stylesheet (or `@use` the Sass entry) to get the default animations, scrim, and CSS custom properties:

```scss
// app/assets/stylesheets/application.scss
@use "katalyst/kpop";

.kpop {
  --animation-duration: 0.3s;
}
```

Override the custom properties inside `.kpop` to change transitions or backdrop colours without rewriting JavaScript.

## Further reading

- `doc/upgrading-to-v4.md` &mdash; highlights everything that changed in the rewrite plus a migration checklist.
- `app/controllers/concerns/katalyst/kpop/frame_request.rb` &mdash; documents the `expects_kpop` behaviour in code.
- `spec/system/*` &mdash; demonstrate the UX guarantees (escape closes, history stays clean, redirects, etc.).

## Development

Releases need to be distributed to rubygems.org and npmjs.org. To do this, you need to have accounts with both providers and be added as a collaborator to the kpop gem and npm packages.

1. Update the version in `katalyst-kpop.gemspec` and run `bundle` to update `Gemfile.lock`
2. Ensure that `rake` passes (format and tests)
3. Tag the release and push the tag to github to run CI/CD

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
