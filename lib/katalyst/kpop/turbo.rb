# frozen_string_literal: true

require "katalyst/kpop/engine"

module Katalyst
  module Kpop
    module Turbo
      class TagBuilder
        delegate :action, :append, :tag, to: :@builder

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
          @builder.action(:kpop_open, id, content, **, &)
        end

        # Render a turbo stream action that will dismiss any open kpop modal.
        def dismiss(id: "kpop")
          append(id) do
            tag.div("", data: {
                      controller:                     "kpop--close",
                      kpop__close_kpop__frame_outlet: "##{id}",
                      turbo_temporary:                "",
                    })
          end
        end

        # Renders a kpop redirect controller response that will escape the frame and navigate to the given URL.
        def redirect_to(url, id: "kpop", target: nil)
          append(id) do
            tag.div("", data: {
                      controller:                        "kpop--redirect",
                      kpop__redirect_kpop__frame_outlet: "##{id}",
                      kpop__redirect_path_value:         url,
                      kpop__redirect_target_value:       target,
                      turbo_temporary:                   "",
                    })
          end
        end
      end
    end
  end
end
