# frozen_string_literal: true

module ScrimHelper
  def scrim_tag
    tag.div(class: "scrim", data: { scrim_target: "scrim", action: "click->scrim#hide", hidden: true })
  end
end
