# frozen_string_literal: true

require "kpop/matchers"

module Kpop
  module Matchers
    class RedirectFinder < CapybaraMatcher
      def initialize
        super("[data-controller='kpop--redirect']")
      end
    end

    # @api private
    class RedirectMatcher < BaseMatcher
      def match(expected, actual)
        actual["data-kpop--redirect-path-value"].to_s.match?(expected)
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

    # @api public
    # Passes if `response` contains a turbo response with a kpop dismiss action.
    #
    # @example
    #   expect(response).to kpop_dismiss
    def kpop_dismiss(id: "kpop")
      ChainedMatcher.new(ResponseMatcher.new,
                         CapybaraParser,
                         StreamMatcher.new(id:, action: "append"))
    end
  end
end