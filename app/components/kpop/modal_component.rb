# frozen_string_literal: true

module Kpop
  class ModalComponent < ViewComponent::Base
    include HasHtmlAttributes

    renders_one :title, "Kpop::Modal::TitleComponent"
    renders_one :header
    renders_one :footer

    def initialize(title:, captive: false, fallback_location: nil, layout: nil, **)
      super

      @fallback_location = fallback_location
      @layout            = layout

      # Generate a title bar. This can be overridden by calling title_bar again.
      with_title(title:, captive:) if title.present?
    end

    def inspect
      "#<#{self.class.name} title: #{title.inspect}>"
    end

    private

    def default_html_attributes
      {
        class: "kpop-modal",
        data: {
          controller:                            "kpop--modal",
          "kpop--modal-fallback-location-value": @fallback_location,
          "kpop--modal-layout-value":            @layout&.to_s&.dasherize,
        },
      }
    end
  end
end
