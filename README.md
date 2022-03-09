# TurboModal
Turbo Frame driven modal 

## Usage

Turbo modal provides helpers to add a basic scrim and modal target frame. These should be placed inside the body:
```html
 <body>
    <%= scrim_tag %>
    <%= modal_tag %>
 </body>
```

### Import turbo_modal styles
```css
/* application.scss */

@import "~@katalyst-interactive/turbo-modal";
```

To get a modal displaying you will need 2 things:
1. A `modal_link` (or programmatic trigger)
2. Some `modal_content`

`modal_link`'s are similar to a `link_to` in rails but it will point the path of the link to target the modal turbo frame.
The resulting path will need to wrap some content in a `modal_content` helper tag.

eg: 
```html
<!-- app/views/homepage/index.html.erb -->
<%= modal_link "click to open modal", modal_path("example") %>
```

```html
<!-- app/views/modals/show.html.erb -->
<%= modal_content do %>
 <div>
     <h1>Modal title</h1>
 </div>
<% end %>
```

## Installation
Run these commands:
```bash
$ bundle add 'turbo_modal'
$ rails turbo_modal:install
```

`rails turbo_modal:install` will add the `turbo_modal` npm packages required. It also sets up stimulus and turbo packages.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
