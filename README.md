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

kpop assumes that you are using importmaps to manage javascript dependencies.

Add the following to your Stimulus `controllers/index.js`:

```js
import kpop from "@katalyst/kpop";
application.load(kpop);
```

This will ensure that kpop is loaded and registered with Stimulus.

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
    <%= render ScrimComponent.new %>
    <%= render Kpop::FrameComponent.new do %>
        <%= yield :kpop %>
    <% end %>
 </body>
```

### Show a modal

To show a modal you need to add content to the kpop turbo frame. You can do this in several ways:
1. Injection 
2. Navigation 

### Injection
Use `content_for :kpop` in an HTML response to inject content into the kpop frame (see `yield :kpop` above).

This allows you to pre open modals when rendering a page without the need for user interaction.

```html
<!-- app/views/homepage/index.html.erb -->
<h1>Site name</h1>
... more html content that will be rendered behind the scrim ...

<% content_for :kpop do %>
  <%= render Kpop::ModalComponent.new(title: "Welcome") do %>
    Thanks for visiting our site!
  <% end %>
```

### Navigation
Respond to a turbo frame request from the kpop frame component.

You can generate a link that will cause a modal to show using the `kpop_link_to` helper.

`kpop_link_to`'s are similar to a `link_to` in rails, but it will navigate to the given URL within the modal turbo
frame. The targeted action will need to generate content in a `Kpop::FrameComponent`, e.g. by responding to a turbo
frame request with the ID `kpop`.

```html
<!-- app/views/homepage/index.html.erb -->
<%= kpop_link_to "click to open modal", modal_path("example") %>
```

```html
<!-- app/views/modals/show.html.erb -->
<%= render Kpop::ModalComponent.new(title: "Modal title") do %>
  Modal content
<% end %>
```

### Turbo Frame Layout

Turbo Frame navigation responses use a layout to add a basic document structure. The `turbo-rails` gem provides the
`turbo_rails/frame` layout, and kpop provides a similar `kpop/frame` layout. If a turbo frame response is requested with
the `kpop` ID, the `kpop/frame` layout will be used automatically.  You can provide an alternative by setting `layout`
in your controller, as usual.

Turbo 8 assumes that the frame response will be a complete HTML document, including a `<head>` and `<body>`, and the
Turbo Visits use the response head to deduce whether the navigation can be snap-shotted or not. This logic lives in
`@hotwire/turbo` in the `Turbo.Visit` constructor:

```javascript
this.isSamePage = this.delegate.locationWithActionIsSamePage(this.location, this.action);
```

If the page is not the same, then the visit is not snap-shotted. Detection looks at turbo-tracked elements in the page
head to make this decision, and history navigation with frames will not work unless the headers are compatible.

As a consequence of this logic, it's really important that the layout used for kpop frame responses is compatible with
the application layout. Kpop provides a "sensible default" that includes stylesheets and javascripts, but if your
application doesn't use the same structure as the Rails default, you'll need to provide your own layout.

If you're experiencing 'strange history behaviour', it's worth putting a breakpoint on the turbo `isSamePage`
calculation to check that the headers are compatible.

## Development

Releases need to be distributed to rubygems.org and npmjs.org. To do this, you need to have accounts with both providers
and be added as a collaborator to the kpop gem and npm packages.

1. Update the version in `katalyst-kpop.gemspec` and run `bundle` to update `Gemfile.lock`
2. Ensure that `rake` passes (format and tests)
3. Tag the release and push the tag to github to run CI/CD

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
