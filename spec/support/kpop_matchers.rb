# frozen_string_literal: true

module KpopMatchers
  def frame
    page.find("turbo-frame#kpop", visible: nil)
  end

  def modal
    page.find("dialog[open]")
  end

  def close_button
    modal.find("button[aria-label='close']")
  end

  def have_modal(label = nil)
    if label.present?
      have_css("dialog[open][aria-label='#{label}']")
    else
      have_css("dialog[open][aria-label]")
    end
  end

  def have_no_modal
    have_no_css("dialog", visible: nil)
  end

  class HaveCapybaraAttribute
    attr_reader :node, :attribute, :expected

    def initialize(attribute, expected)
      @attribute = attribute
      @expected = expected
    end

    def describe_node
      if @node.is_a?(Capybara::Node::Element)
        @node.tag_name
      else
        @node.inspect
      end
    end

    def actual
      node[attribute]
    end

    def matches?(node)
      @node = node
      actual.eql?(expected)
    end

    def failure_message
      "expected #{describe_node} to have #{attribute}=#{expected.inspect} but was #{actual.inspect}"
    end

    def failure_message_when_negated
      "expected #{describe_node} not to have #{attribute}=#{expected.inspect}"
    end
  end

  def have_src(path)
    HaveCapybaraAttribute.new(:src, path)
  end
end
