# frozen_string_literal: true

module Kpop
  module Modal
    class FooterComponent < ViewComponent::Base
      include Katalyst::HtmlAttributes

      def call
        tag.div(content, **html_attributes)
      end

      def inspect
        "#<#{self.class.name}>"
      end

      def default_html_attributes
        { class: "kpop-footer" }
      end
    end
  end
end
