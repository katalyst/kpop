# frozen_string_literal: true

module Kpop
  class ModalComponent < ViewComponent::Base
    include HasHtmlAttributes

    renders_one :title, "Kpop::Modal::TitleComponent"
    renders_one :header
    renders_one :footer

    def initialize(title:, captive: false, **)
      super

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
        data:  {
          controller:           "kpop--modal",
          "kpop--frame-target": "modal",
        },
      }
    end
  end
end
