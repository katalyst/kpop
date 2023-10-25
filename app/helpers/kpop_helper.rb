# frozen_string_literal: true

module KpopHelper
  using HTMLAttributesUtils

  # Render a turbo stream action that will dismiss any open kpop modals.
  def kpop_dismiss(id: "kpop")
    turbo_stream.append(id) do
      tag.div("", data: {
                controller:                     "kpop--close",
                kpop__close_kpop__frame_outlet: "##{id}",
                turbo_temporary:                "",
              })
    end
  end

  # Renders a kpop redirect controller response that will escape the frame and navigate to the given URL.
  def kpop_redirect_to(url, id: "kpop", target: nil)
    turbo_stream.append(id) do
      tag.div("", data: {
                controller:                        "kpop--redirect",
                kpop__redirect_kpop__frame_outlet: "##{id}",
                kpop__redirect_path_value:         url,
                kpop__redirect_target_value:       target,
                turbo_temporary:                   "",
              })
    end
  end

  # Renders a link that will navigate the kpop turbo frame to the given URL.
  # The URL should render a modal response inside a kpop frame tag.
  def kpop_link_to(name = nil, options = nil, html_attributes = nil, &block)
    default_html_attributes = { data: { turbo_frame: "kpop" } }
    if block
      # Param[name] is the path for the link
      link_to(name, default_html_attributes.deep_merge_html_attributes(options || {}), &block)
    else
      link_to(name, options, default_html_attributes.deep_merge_html_attributes(html_attributes || {}))
    end
  end

  # Renders a button that will navigate the kpop turbo frame to the given URL.
  # The URL should render a modal response inside a kpop frame tag.
  def kpop_button_to(name = nil, options = nil, html_attributes = nil, &)
    default_html_attributes = {
      form: { data: { turbo_frame: "kpop" } },
    }
    button_to(name, options, default_html_attributes.deep_merge_html_attributes(html_attributes || {}), &)
  end

  # Renders a button that will close the current kpop modal, if any.
  def kpop_button_close(content = nil, **, &block)
    content = capture(yield) if block
    tag.button(content, data: { action: "click->kpop--frame#dismiss:prevent" }, **)
  end
end
