# kpop

Modals driven by `@hotwire/turbo` frame navigation.

kpop requires `@hotwire/turbo` and `@hotwire/stimulus` to be installed and configured correctly to be used.

## Installation

Install gem
```bash
# Gemfile

$ bundle add "katalyst-kpop"
```

kpop supports installation of javascript dependencies with either import maps or yarn.

### Stimulus controllers

If you are using asset pipeline and import maps then the stimulus controllers
for modals and scrim will be automatically available without configuration.

### Stylesheets

Import stylesheets through using SASS using asset pipeline:

```scss 
// app/assets/stylesheets/application.scss

@use "katalyst/kpop";
```

## Usage

kpop provides helpers to add a basic scrim and modal target frame. These should be placed inside the body:
```html
 <body>
    <%= scrim_tag %>
    <%= kpop_frame_tag do %>
        <%= yield :kpop %>
    <% end %>
 </body>
```

### Show a modal

To show a modal you need to add content to the kpop turbo frame. You can do this in several ways:
1. Use `content_for :kpop` in an HTML response to inject content into the kpop frame (see `yield :kpop` above)
2. Use `layout "kpop"` in your controller to wrap your turbo response in a kpop frame

You can generate a link that will cause a modal to show using the `kpop_link_to` helper.

`kpop_link_to`'s are similar to a `link_to` in rails, but it will navigate to the given URL within the modal turbo
frame. The targeted action will need to generate content in a `kpop_frame_tag`, e.g. using `layout "kpop"`.

```html
<!-- app/views/homepage/index.html.erb -->
<%= modal_link_to "click to open modal", modal_path("example") %>
```

```html
<!-- app/views/modals/show.html.erb -->
<%= render_kpop(title: "Modal title") do %>
 Modal content
<% end %>
```

Note that, because kpop modals render in a turbo frame, if you want to navigate the parent frame you will need to use
`target: "_top"` on your links and forms, or add `target: "_top"` to the `kpop_frame_tag` call in your body.

## Development

Releases need to be distributed to rubygems.org and npmjs.org. To do this, you need to have accounts with both providers
and be added as a collaborator to the kpop gem and npm packages.

1. Update the version in `lib/katalyst/kpop/version.rb`
2. Ensure that `rake` passes (format and tests)
3. Tag a release and push to rubygems.org by running `rake release`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
