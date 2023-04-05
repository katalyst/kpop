# frozen_string_literal: true

require_relative "lib/katalyst/kpop/version"

Gem::Specification.new do |spec|
  spec.name    = "katalyst-kpop"
  spec.version = Katalyst::Kpop::VERSION
  spec.authors = ["Katalyst Interactive"]
  spec.email   = ["developers@katalyst.com.au"]

  spec.summary               = "Modal library that uses Turbo and Stimulus."
  spec.homepage              = "https://github.com/katalyst/kpop"
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files                             = Dir["{app,config,lib}/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths                     = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
