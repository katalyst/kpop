# frozen_string_literal: true

module Kpop
  class FrameComponent < ViewComponent::Base
    include Katalyst::HtmlAttributes
    include Turbo::FramesHelper

    attr_reader :id

    ACTIONS = %w[
      turbo:before-fetch-request@window->kpop--frame#beforeFetchRequest
      turbo:before-frame-render->kpop--frame#beforeFrameRender
      turbo:before-stream-render@window->kpop--frame#beforeStreamRender
      turbo:before-visit@window->kpop--frame#beforeVisit
      turbo:frame-load->kpop--frame#frameLoad
    ].freeze

    def initialize(id: "kpop", **)
      super(**)

      @id = id
    end

    def modal_flash?
      request.get? && flash.key?(:modal_location)
    end

    def modal_location
      flash[:modal_location] if modal_flash?
    end

    def inspect
      "#<#{self.class.name} id: #{id.inspect}>"
    end

    private

    def default_html_attributes
      {
        class:  "kpop",
        data:   {
          controller: "kpop--frame",
          action:     ACTIONS.join(" "),
        },
        src:    modal_location,
        target: "_top",
      }
    end
  end
end
