# frozen_string_literal: true

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class TitleMatcher < Base
        def description
          "contain a kpop modal with title #{expected.inspect}"
        end

        def match(expected, actual) # rubocop:disable Naming/PredicateMethod
          expected.match?(actual.text)
        end

        def failure_message
          "expected a kpop modal with title #{expected.inspect} but received #{actual.native.to_html.inspect} instead"
        end

        def failure_message_when_negated
          "expected not to find a kpop modal with title #{expected}"
        end
      end
    end
  end
end
