# frozen_string_literal: true

module ScrimHelper
  def scrim_tag(z_index: 40)
    tag.div(class: "scrim", data: { controller: "scrim", scrim_z_index_value: z_index, action: <<~ACTIONS })
      click->scrim#dismiss
      keyup@window->scrim#escape
      scrim:request:hide@window->scrim#hide
      scrim:request:show@window->scrim#show
      turbo:before-cache@document->scrim#hide
    ACTIONS
  end
end
