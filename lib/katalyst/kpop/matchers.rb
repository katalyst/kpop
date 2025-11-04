# frozen_string_literal: true

module Katalyst
  module Kpop
    module Matchers
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

      # @api public
      # Passes if `response` contains a kpop turbo frame src set.
      # Supports matching on:
      #  * id – turbo frame id
      #  * location - modal location (path)
      #
      # @example Matching a response that will async load `/cart` as a modal
      #   expect(response).to have_kpop_src("/cart")
      def have_kpop_src(location, id: "kpop") # rubocop:disable Naming/PredicatePrefix
        ChainedMatcher.new(ResponseMatcher, CapybaraParser, FrameMatcher.new(id:), SrcMatcher.new(location))
      end
    end
  end
end
