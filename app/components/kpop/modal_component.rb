# frozen_string_literal: true

module Kpop
  class ModalComponent < ViewComponent::Base
    include HasHtmlAttributes

    ACTIONS = %w[
      popstate@window->kpop--modal#popstate
      turbo:before-cache@window->kpop--modal#beforeCache
      turbo:before-visit@window->kpop--modal#beforeVisit
    ].freeze

    renders_one :title, "Kpop::Modal::TitleComponent"
    renders_one :header
    renders_one :footer

    def initialize(title:, captive: false, temporary: true, **)
      super

      @temporary = temporary

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
          controller:                    "kpop--modal",
          action:                        ACTIONS.join(" "),
          "kpop--frame-target":          "modal",
          "kpop--modal-temporary-value": @temporary,
        },
      }
    end
  end
end
