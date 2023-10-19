# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("dummy/spec/rails_helper", __dir__)

Dir[Katalyst::Kpop::Engine.root.join("spec", "support", "**", "*.rb")].each do |f|
  require f
end

require "kpop/matchers"

module DisableScreenshots
  def take_failed_screenshot
    # no-op
  end
end

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component

  config.include Capybara::RSpecMatchers, type: :component
  config.include Capybara::RSpecMatchers, type: :request

  config.define_derived_metadata(file_path: %r{spec/components}) do |metadata|
    metadata[:type] ||= :component
  end

  # https://github.com/rspec/rspec-rails/issues/2690
  config.include DisableScreenshots, type: :system
end
