# frozen_string_literal: true

require "katalyst/kpop/engine"

module Katalyst
  module Kpop
    module Turbo
      class TagBuilder
        delegate :action, :turbo_stream_action_tag, to: :@builder

        def initialize(builder)
          @builder = builder
        end

        # Open a modal in the kpop frame identified by <tt>id</tt> either the <tt>content</tt> passed in or a
        # rendering result determined by the <tt>rendering</tt> keyword arguments, the content in the block,
        # or the rendering of the content as a record. Examples:
        #
        #   <%= turbo_stream.kpop.open modal %>
        #   <%= turbo_stream.kpop.open partial: "modals/modal", locals: { record: } %>
        #   <%= turbo_stream.kpop.open do %>
        #     <%= render Kpop::ModalComponent.new(title: "Example") do %>
        #       ...
        #     <% end %>
        #   <% end %>
        def open(content = nil, id: "kpop", **, &)
          action(:kpop_open, id, content, **, &)
        end

        # Render a turbo stream action that will dismiss any open kpop modal.
        def dismiss(id: "kpop")
          turbo_stream_action_tag(:kpop_dismiss, target: id)
        end

        # Renders a kpop redirect controller response that will escape the frame and navigate to the given URL.
        # Note: turbo does not currently snapshot page history accurately when using "advance" (Oct 23).
        def redirect_to(href, id: "kpop", action: "replace", target: nil)
          turbo_stream_action_tag(
            :kpop_redirect_to,
            target: id,
            href:,
            data:   {
              turbo_action: action,
              turbo_frame:  target,
            },
          )
        end
      end
    end
  end
end
