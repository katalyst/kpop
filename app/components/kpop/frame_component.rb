# frozen_string_literal: true

module Kpop
  class FrameComponent < ViewComponent::Base
    include HasHtmlAttributes
    include Turbo::FramesHelper

    attr_reader :id

    ACTIONS = %w[
      scrim:hide@window->kpop--frame#dismiss
    ].freeze

    def initialize(id: "kpop", scrim: "#scrim", **)
      super

      @id              = id
      @scrim           = scrim
    end

    def inspect
      "#<#{self.class.name} id: #{id.inspect}>"
    end

    private

    def default_html_attributes
      {
        class:  "kpop-container",
        data:   {
          controller:                 "kpop--frame",
          action:                     ACTIONS.join(" "),
          "kpop--frame-scrim-outlet": @scrim,
        },
        target: "_top",
      }
    end
  end
end
