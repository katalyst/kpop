# TurboModal
Modal's driven through `@hotwire/turbo`

Turbo modal requires `@hotwire/turbo` and `@hotwire/stimulus` to be installed and configured correctly to be used.

## Installation
Install gem
```bash
# Gemfile

$ bundle add "turbo_modal"
```
Turbo modal supports installation of javascript dependencies with either import maps or yarn.

### Import maps
Pin stimulus controllers
```ruby 
# app/config/importmap.rb

pin "controllers/scrim_controller", to: "controllers/scrim_controller.js"
pin "controllers/modal_controller", to: "controllers/modal_controller.js"
pin "controllers/modal_link_controller", to: "controllers/modal_link_controller.js"
```

Configure asset pipeline to use turbo_modal
``` js
// app/assets/config/<project>.js

//= link turbo_modal.js
```

import stylesheets through asset pipline
```scss 
// app/assets/stylesheets/application.scss/css

@import "turbo_modal";
```

### Yarn
Install npm package
```bash
$ yarn add "@katalyst-interactive/turbo-modal"
```
### Import turbo_modal styles
```css
/* application.scss */

@import "~@katalyst-interactive/turbo-modal";
```

### Import turbo_modal stimulus controllers
```js
/* application.js */
import TurboModal from "@katalyst-interactive/turbo-modal"
application.load(TurboModal)
```

## Usage

Turbo modal provides helpers to add a basic scrim and modal target frame. These should be placed inside the body:
```html
 <body>
    <%= scrim_tag %>
    <%= modal_tag %>
 </body>
```

### Show a modal

To get a modal displaying you will need 2 things:
1. A `modal_link` (or programmatic trigger)
2. Some `modal_content`

`modal_link`'s are similar to a `link_to` in rails, but it will navigate to the given URL within the modal turbo frame.
The resulting path will need to wrap some content in a `modal_content` helper tag.

eg: 
```html
<!-- app/views/homepage/index.html.erb -->
<%= modal_link_to "click to open modal", modal_path("example") %>
```

```html
<!-- app/views/modals/show.html.erb -->
<%= modal_content do %>
 <div>
     <h1>Modal title</h1>
 </div>
<% end %>
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
