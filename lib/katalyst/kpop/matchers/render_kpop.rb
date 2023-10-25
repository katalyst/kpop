# frozen_string_literal: true

module Katalyst
  module Kpop
    module Matchers
      # @api private
      class ModalMatcher < CapybaraMatcher
        def initialize
          super("[data-controller*='kpop--modal']")
        end

        def description
          "contain a kpop modal"
        end
      end

      # @api private
      class TitleFinder < CapybaraMatcher
        def initialize
          super(".kpop-title")
        end
      end

      # @api private
      class TitleMatcher < BaseMatcher
        def description
          "contain a kpop modal with title #{expected.inspect}"
        end

        def match(expected, actual)
          expected.match?(actual.text)
        end

        def failure_message
          "expected a kpop modal with title #{expected.inspect} but received #{actual.native.to_html.inspect} instead"
        end

        def failure_message_when_negated
          "expected not to find a kpop modal with title #{expected}"
        end
      end

      # @api public
      # Passes if `response` contains a turbo stream response with a kpop modal.
      # Supports matching on:
      #  * id – kpop frame id
      #  * title - modal title
      #
      # @example Matching turbo stream response with a Shopping Cart modal
      #   expect(response).to render_kpop_stream(title: "Shopping Cart")
      def render_kpop_stream(id: "kpop", title: nil)
        matcher = ChainedMatcher.new(ResponseMatcher, CapybaraParser, StreamMatcher.new(id:, action: "kpop_open"),
                                     ModalMatcher)
        matcher << TitleFinder << TitleMatcher.new(title) if title.present?
        matcher
      end

      # @api public
      # Passes if `response` contains a turbo frame with a kpop modal.
      # Supports matching on:
      #  * id – turbo frame id
      #  * title - modal title
      #
      # @example Matching turbo stream response with a Shopping Cart modal
      #   expect(response).to render_kpop_frame(title: "Shopping Cart")
      def render_kpop_frame(id: "kpop", title: nil)
        matcher = ChainedMatcher.new(ResponseMatcher.new, CapybaraParser, FrameMatcher.new(id:), ModalMatcher)
        matcher << TitleFinder << TitleMatcher.new(title) if title.present?
        matcher
      end
    end
  end
end
