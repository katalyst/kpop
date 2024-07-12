# frozen_string_literal: true

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class FrameMatcher < CapybaraMatcher
        def initialize(id: "kpop")
          super("turbo-frame##{id}")
        end
      end
    end
  end
end
