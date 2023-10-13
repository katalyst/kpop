# frozen_string_literal: true

module Kpop
  module Matchers
    class BaseMatcher < RSpec::Rails::Matchers::BaseMatcher
      attr_reader :matched

      def matches?(actual)
        @matched = super
        @matched.present?
      end
    end

    # @api private
    class CapybaraMatcher < BaseMatcher
      attr_reader :matched

      def matches?(actual)
        super
      rescue Capybara::ElementNotFound
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

    # @api private
    class ResponseMatcher < BaseMatcher
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

    # @api private
    class CapybaraParser < BaseMatcher
      def match(_, actual)
        @html = Nokogiri::HTML5.parse(actual.body)
        Capybara::Node::Simple.new(@html)
      end
    end

    class ChainedMatcher < RSpec::Rails::Matchers::BaseMatcher
      Input = Struct.new(:matched)

      delegate :failure_message, :failure_message_when_negated, to: :@matcher

      def initialize(*matchers)
        super()
        matchers.each { |m| self << m }
      end

      def <<(matcher)
        matcher = matcher.new if matcher.is_a?(Class)
        (@matchers ||= []) << matcher
        self
      end

      def match(_, actual)
        @matcher = Input.new(actual)
        @matchers.all? do |matcher|
          input = @matcher.matched
          @matcher = matcher
          matcher.matches?(input)
        end
      end

      def description
        @matchers.last.description
      end
    end

    # @api private
    class StreamMatcher < CapybaraMatcher
      def initialize(id: "kpop", action: "update")
        super("turbo-stream[action='#{action}'][target='#{id}']")
      end
    end

    # @api private
    class FrameMatcher < CapybaraMatcher
      def initialize(id: "kpop")
        super("turbo-frame##{id}")
      end
    end
  end
end

require "kpop/matchers/redirect_to"
require "kpop/matchers/render_kpop"
require "kpop/matchers/kpop_dismiss"

RSpec.configure do |config|
  config.include Kpop::Matchers, type: :component
  config.include Kpop::Matchers, type: :request
end
