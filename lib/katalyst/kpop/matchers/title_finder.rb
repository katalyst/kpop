# frozen_string_literal: true

require "katalyst/kpop/matchers/capybara_matcher"

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class TitleFinder < CapybaraMatcher
        def initialize
          super(".kpop-title")
        end
      end
    end
  end
end
