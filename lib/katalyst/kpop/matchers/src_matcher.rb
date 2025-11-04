# frozen_string_literal: true

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class SrcMatcher < Base
        def description
          "contain a kpop frame with src #{expected.inspect}"
        end

        def match(expected, actual) # rubocop:disable Naming/PredicateMethod
          case expected
          when String
            actual[:src].to_s.eql?(expected)
          when Regexp
            actual[:src].to_s.match?(expected)
          else
            raise ArgumentError, expected
          end
        end

        def failure_message
          "expected a kpop frame with src #{expected.inspect} but received #{actual.native.to_html.inspect} instead"
        end

        def failure_message_when_negated
          "expected not to find a kpop frame with src #{expected}"
        end
      end
    end
  end
end
