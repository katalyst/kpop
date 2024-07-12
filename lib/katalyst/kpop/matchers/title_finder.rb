# frozen_string_literal: true

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
