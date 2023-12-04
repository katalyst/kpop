# frozen_string_literal: true

module Kpop
  class ModalComponent < ViewComponent::Base
    include Katalyst::HtmlAttributes

    renders_one :title, "Kpop::Modal::TitleComponent"
    renders_one :header, "Kpop::Modal::HeaderComponent"
    renders_one :footer, "Kpop::Modal::FooterComponent"

    define_html_attribute_methods :content_attributes

    def initialize(title:, fallback_location: nil, layout: nil, captive: false, **html_attributes)
      self.content_attributes = html_attributes.delete(:content) if html_attributes.key?(:content)

      super(**html_attributes)

      @fallback_location = fallback_location
      @layout            = layout

      # Generate a title bar. This can be overridden by calling title_bar again.
      with_title(title:, captive:) if title.present?
    end

    def with_footer_buttons(**, &)
      with_footer(class: "button-set", **, &)
    end

    def inspect
      "#<#{self.class.name} title: #{title.inspect}>"
    end

    private

    def default_html_attributes
      {
        class: "kpop-modal",
        data:  {
          controller:                            "kpop--modal",
          "kpop--modal-current-location-value":  request.path,
          "kpop--modal-fallback-location-value": @fallback_location,
          "kpop--modal-layout-value":            @layout&.to_s&.dasherize,
        },
      }
    end

    def default_content_attributes
      { class: "kpop-content" }
    end
  end
end
