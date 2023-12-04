# frozen_string_literal: true

module Kpop
  module Modal
    class TitleComponent < ViewComponent::Base
      include Katalyst::HtmlAttributes

      def initialize(title: nil, captive: false, **)
        super

        @title = title
        @captive = captive
      end

      def title
        content? ? content : @title
      end

      def captive?
        @captive
      end

      def inspect
        "#<#{self.class.name} title: #{title.inspect}>"
      end
    end
  end
end
