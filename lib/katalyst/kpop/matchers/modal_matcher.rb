# frozen_string_literal: true

require "katalyst/kpop/matchers/capybara_matcher"

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class ModalMatcher < CapybaraMatcher
        def initialize
          super("[data-controller*='kpop--modal']")
        end

        def description
          "contain a kpop modal"
        end
      end
    end
  end
end
