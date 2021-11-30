require_relative "lib/turbo_modal/version"

Gem::Specification.new do |spec|
  spec.name        = "turbo_modal"
  spec.version     = TurboModal::VERSION
  spec.authors     = ["Alan Cornthwaite", "Matt Redmond"]
  spec.email       = ["alan.cornthwaite@katalyst.com.au", "matt.redmond@katalyst.com.au"]
  spec.homepage    = "https://github.com/katalyst/turbo_modal"
  spec.summary     = "Modal library that uses Turbo and Stimulus because we are in the future now."
  spec.description = ""
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.3", ">= 6.1.3.1"
  spec.add_dependency "turbo-rails", "~> 0.7", "< 1.0"
end
