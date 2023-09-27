# frozen_string_literal: true

# rubocop:disable Rails/HelperInstanceVariable
module Kpop
  class Modal
    delegate_missing_to :@context

    def initialize(context)
      @context = context
    end

    def render(options = {})
      dom_class = options.delete(:class)

      # Generate a title bar. This can be overridden by calling title_bar again.
      title_bar(options) unless options.fetch(:title, "").nil?

      # Render block. This may have side-effect writes to header/content/footer
      # etc. If @content is set then this value will be ignored.
      content = capture do
        yield self
      end

      tag.div(class: class_names("kpop-modal", dom_class),
              data:  kpop_data_options(options),
              **options) do
        concat @title_bar
        concat @header if @header.present?
        concat @content.presence || tag.div(content, class: "kpop-content")
        concat @footer if @footer.present?
      end
    end

    # Generates a sticky title bar for the modal. Content should not be too long
    # as the bar does not provide wrapping.
    def title_bar(options = {}, &block)
      title      = options.delete(:title)
      captive    = options.delete(:captive)
      @title_bar = tag.div(class: "kpop-title-bar", **options) do
        concat(tag.span(class: "kpop-title") do
          concat(block ? (yield self) : title)
        end)
        concat(close_icon) unless captive
      end
      nil
    end

    # Generates sticky header content for the top of the modal. Content is not
    # padded, if you want padding you should provide a padding class.
    def header(...)
      modal_content(...)
    end

    # Generates content for the modal. Content is not padded, if you want
    # padding you should provide a padding class.
    def content(...)
      modal_content(...)
    end

    # Generates a sticky footer element at the bottom of the modal.
    # Footer is padded and contents are assumed to be buttons.
    def footer(...)
      modal_content(...)
    end

    def close_icon
      tag.button(
        "×",
        class: "kpop-close",
        data:  {
          kpop_target: "closeButton",
          action:      "click->kpop#dismiss:prevent",
        },
      )
    end

    private

    def kpop_data_options(options)
      data = options.delete(:data) || {}
      data.reverse_merge(
        kpop_target:    "content",
        dismiss_action: options.delete(:dismiss_action),
        dismiss_url:    options.delete(:dismiss_url),
      )
    end

    def class_for(name, options)
      class_names("kpop-#{name}", options.delete(:class))
    end

    def modal_content(name, **options, &block)
      instance_variable_set("@#{name}", tag.div(class: class_for(name, options), **options, &block))
      nil
    end
  end
end
# rubocop:enable Rails/HelperInstanceVariable
