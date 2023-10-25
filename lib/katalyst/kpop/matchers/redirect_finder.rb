# frozen_string_literal: true

require "katalyst/kpop/matchers/capybara_matcher"

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class RedirectFinder < CapybaraMatcher
        def initialize
          super("[data-controller='kpop--redirect']")
        end
      end
    end
  end
end
