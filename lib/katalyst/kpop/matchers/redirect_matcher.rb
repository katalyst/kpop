# frozen_string_literal: true

require "katalyst/kpop/matchers/base"

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class RedirectMatcher < Base
        def match(expected, actual)
          actual["href"].to_s.match?(expected)
        end

        def description
          "kpop redirect to #{expected.inspect}"
        end

        def failure_message
          "expected a kpop redirect to #{expected.inspect} but received #{actual.native.to_html.inspect} instead"
        end

        def failure_message_when_negated
          "expected not to find a kpop redirect to #{expected.inspect}"
        end
      end
    end
  end
end
