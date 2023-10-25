# frozen_string_literal: true

require "katalyst/kpop/matchers/base"

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class CapybaraMatcher < Base
        attr_reader :matched

        def matches?(actual)
          super
        rescue ::Capybara::ElementNotFound
          nil
        end

        def match(expected, actual)
          actual.find(expected)
        end

        def description
          "match #{expected}"
        end

        def describe_expected
          expected.inspect
        end

        def describe_actual
          response = actual.native.children.to_html.gsub(/\s+/, " ")
          response = "#{response[0..120]}..." if response.length > 120
          response.inspect
        end

        def failure_message
          "expected #{describe_expected} but received #{describe_actual} instead"
        end

        def failure_message_when_negated
          "expected not to find #{expected}"
        end
      end
    end
  end
end
