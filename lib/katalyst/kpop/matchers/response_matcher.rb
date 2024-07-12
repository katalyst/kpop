# frozen_string_literal: true

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class ResponseMatcher < Base
        def match(_, actual)
          case actual
          when ::ActionDispatch::Response
            ::ActionDispatch::TestResponse.from_response(actual)
          when ::ActionDispatch::TestResponse
            actual
          end
        end

        def description
          "a response"
        end

        def failure_message
          "expected a response but received #{actual.inspect} instead"
        end

        def failure_message_when_negated
          "expected not to receive a response"
        end
      end
    end
  end
end
