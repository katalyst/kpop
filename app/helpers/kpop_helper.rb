# frozen_string_literal: true

module KpopHelper
  def render_kpop(options = {}, &block)
    Kpop::Modal.new(self).render(options, &block)
  end

  def kpop_frame_tag(&block)
    turbo_frame_tag "kpop",
                    class: "kpop-container",
                    data:  { controller: "kpop", action: "scrim:hide@window->kpop#dismiss" } do
      capture(&block) if block
    end
  end

  def kpop_link_to(name = nil, options = nil, html_options = nil, &block)
    default_html_options = {
      data: { turbo: true, turbo_frame: "kpop" },
    }
    if block
      # Param[name] is the path for the link
      link_to(name, default_html_options.deep_merge(options || {}), &block)
    else
      link_to(name, options, default_html_options.deep_merge(html_options || {}))
    end
  end

  def kpop_button_to(name = nil, options = nil, html_options = nil, &block)
    default_html_options = {
      form: { data: { turbo: true, turbo_frame: "kpop" } },
    }
    button_to(name, options, default_html_options.deep_merge(html_options || {}), &block)
  end

  def kpop_button_close(content = nil, **options, &block)
    content = block ? capture(yield) : content
    tag.button content, data: { action: "click->kpop#dismiss:prevent" }, **options
  end
end
