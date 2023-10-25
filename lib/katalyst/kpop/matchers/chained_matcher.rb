# frozen_string_literal: true

require "rspec/rails/matchers/base_matcher"

module Katalyst
  module Kpop
    module Matchers
      # @api private
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
            input    = @matcher.matched
            @matcher = matcher
            matcher.matches?(input)
          end
        end

        def description
          @matchers.last.description
        end
      end
    end
  end
end
