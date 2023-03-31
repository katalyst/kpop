# frozen_string_literal: true

require_relative "lib/turbo_modal/version"

Gem::Specification.new do |spec|
  spec.name    = "turbo_modal"
  spec.version = TurboModal::VERSION
  spec.authors = ["Katalyst Interactive"]
  spec.email   = ["developers@katalyst.com.au"]

  spec.summary               = "Modal library that uses Turbo and Stimulus."
  spec.homepage              = "https://github.com/katalyst/turbo_modal"
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files                             = Dir["{app,config,lib}/**/*", "CHANGELOG.md", "LICENSE.txt", "README.md"]
  spec.require_paths                     = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
