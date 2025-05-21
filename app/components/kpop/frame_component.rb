# frozen_string_literal: true

module Kpop
  class FrameComponent < ViewComponent::Base
    include Katalyst::HtmlAttributes
    include Turbo::FramesHelper

    attr_reader :id

    ACTIONS = %w[
      popstate@window->kpop--frame#popstate
      scrim:dismiss@window->kpop--frame#dismiss
      scrim:hide@window->kpop--frame#dismiss
      turbo:before-frame-render->kpop--frame#beforeFrameRender
      turbo:before-stream-render@window->kpop--frame#beforeStreamRender
      turbo:before-visit@window->kpop--frame#beforeVisit
      turbo:frame-load->kpop--frame#frameLoad
    ].freeze

    def initialize(id: "kpop", scrim: "#scrim", **)
      super(**)

      @id    = id
      @scrim = scrim
    end

    def inspect
      "#<#{self.class.name} id: #{id.inspect}>"
    end

    private

    def default_html_attributes
      {
        class:  "kpop--frame",
        data:   {
          controller:                 "kpop--frame",
          action:                     ACTIONS.join(" "),
          "kpop--frame-scrim-outlet": @scrim,
          turbo_action:               "advance",
        },
        target: "_top",
      }
    end
  end
end
