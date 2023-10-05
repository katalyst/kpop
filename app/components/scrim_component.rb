# frozen_string_literal: true

class ScrimComponent < ViewComponent::Base
  attr_reader :id, :z_index

  ACTIONS = %w[
    animationend->scrim#animationEnd
    click->scrim#dismiss
    keyup@window->scrim#escape
    turbo:before-cache@document->scrim#beforeCache
  ].freeze

  def initialize(id: "scrim", z_index: 40)
    super

    @id      = id
    @z_index = z_index
  end

  def call
    tag.div(id:,
            class: "scrim",
            data:  {
              controller:          "scrim",
              scrim_z_index_value: z_index,
              action:              ACTIONS.join(" "),
            })
  end

  def inspect
    "#<#{self.class.name} id: #{id.inspect}>"
  end
end
