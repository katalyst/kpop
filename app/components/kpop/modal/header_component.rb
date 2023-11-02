# frozen_string_literal: true

module Kpop
  module Modal
    class HeaderComponent < ViewComponent::Base
      include HasHtmlAttributes

      def call
        tag.div(content, **html_attributes)
      end

      def inspect
        "#<#{self.class.name}>"
      end

      def default_html_attributes
        { class: "kpop-header" }
      end
    end
  end
end
