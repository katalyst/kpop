# frozen_string_literal: true

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class StreamMatcher < CapybaraMatcher
        def initialize(id: "kpop", action: "update")
          super("turbo-stream[action='#{action}'][target='#{id}']")
        end
      end
    end
  end
end
