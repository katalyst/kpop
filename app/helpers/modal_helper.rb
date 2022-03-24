# frozen_string_literal: true

module ModalHelper
  MODAL_ID     = "modal"
  LINK_OPTIONS = { data: {
    turbo_frame: MODAL_ID,
    controller:  "modal-link",
    action:      "modal-link#onClick",
    modal_type:  "",
  } }.freeze

  def modal_tag(modal_id = MODAL_ID)
    turbo_frame_tag modal_id, data: { controller: "modal", modal_target: "turboFrame", action: <<~ACTIONS }
      modal:open@window->modal#open
      modal:close@window->modal#close
    ACTIONS
  end

  # @see ActionView::Helpers::UrlHelper#link_to for argument details
  def modal_link_to(name = nil, options = nil, html_options = nil, &block)
    if block
      link_to name, LINK_OPTIONS.deep_merge(options || {}), &block
    else
      link_to name, options, LINK_OPTIONS.deep_merge(html_options || {})
    end
  end

  alias modal_link modal_link_to

  def modal_content(options = {}, &block)
    modal_id = options.fetch(:modal_id, MODAL_ID)
    turbo_frame_tag modal_id, data: { hidden: "" } do
      tag.div(class: "modal animate-in #{options.delete(:modal_classes)}",
              data: {
                action: <<~ACTIONS
                  keyup@window->modal#keyup
                  scrim:hide@window->modal#close
                ACTIONS
              }) do
        yield if block
      end
    end
  end
end
