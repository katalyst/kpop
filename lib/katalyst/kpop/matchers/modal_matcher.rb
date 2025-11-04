# frozen_string_literal: true

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class ModalMatcher < CapybaraMatcher
        def initialize
          super("dialog")
        end

        def description
          "contain a kpop modal"
        end
      end
    end
  end
end
