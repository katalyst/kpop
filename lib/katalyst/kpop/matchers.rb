# frozen_string_literal: true

module Katalyst
  module Kpop
    module Matchers
      # @api public
      # Passes if `response` contains a turbo response with a kpop dismiss action.
      #
      # @example
      #   expect(response).to kpop_dismiss
      def kpop_dismiss(id: "kpop")
        ChainedMatcher.new(ResponseMatcher,
                           CapybaraParser,
                           StreamMatcher.new(id:, action: "kpop_dismiss"))
      end

      # @api public
      # Passes if `response` contains a turbo response with a kpop redirect to
      # the provided `target`.
      #
      # @example Matching a path against a turbo response containing a kpop redirect
      #   expect(response).to kpop_redirect_to("/path/to/resource")
      def kpop_redirect_to(target, id: "kpop")
        raise ArgumentError, "Invalid target: nil" unless target

        ChainedMatcher.new(ResponseMatcher,
                           CapybaraParser,
                           StreamMatcher.new(id:, action: "kpop_redirect_to"),
                           RedirectMatcher.new(target))
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
        matcher = ChainedMatcher.new(ResponseMatcher, CapybaraParser, FrameMatcher.new(id:), ModalMatcher)
        matcher << TitleFinder << TitleMatcher.new(title) if title.present?
        matcher
      end
    end
  end
end
