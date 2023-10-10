# frozen_string_literal: true

require "capybara/rspec"
require "capybara/cuprite"

RSpec.configure do |config|
  Capybara.default_driver = Capybara.javascript_driver = :cuprite

  Capybara.server                = :puma, { Silent: true }
  Capybara.disable_animation     = true

  # Rails will set `:selenium` as the runner for system tests by default, but this happens after `before` hooks.
  # We want to use our configured javascript driver and ensure that this is set before
  # our before hooks run so that we can log in (etc).
  config.prepend_before(:all, type: :system) do
    driven_by :cuprite, screen_size: [1920, 1080], options: { headless: true, inspector: false }
  end

  config.include Capybara::RSpecMatchers, type: :request
end
