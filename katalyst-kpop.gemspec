# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "katalyst-kpop"
  spec.version = "3.3.0"
  spec.authors = ["Katalyst Interactive"]
  spec.email   = ["developers@katalyst.com.au"]

  spec.summary               = "Modal library that uses Turbo and Stimulus."
  spec.homepage              = "https://github.com/katalyst/kpop"
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files                             = Dir["{app,config,lib/katalyst}/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths                     = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "katalyst-html-attributes"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "view_component", ">= 4.0.0"
end
