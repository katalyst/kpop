# frozen_string_literal: true

module ScrimHelper
  def scrim_tag
    tag.div(class: "scrim", data: { controller: "scrim", scrim_target: "scrim", action: <<~ACTIONS, hidden: true })
      click->scrim#onClick
      scrim:hide@window->scrim#hide
      scrim:show@window->scrim#show
    ACTIONS
  end
end
