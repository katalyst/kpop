# frozen_string_literal: true

require "html_attributes_utils"

module Kpop
  # Adds HTML attributes to a component.
  # Accepts HTML attributes from the constructor or via `html_attributes=`.
  # These are merged with the default attributes defined in the component.
  # Adds support for custom html attributes for other tags, e.g.:
  #   define_html_attribute_methods :table_attributes, default: {}
  #   tag.table(**table_attributes)
  module HasHtmlAttributes
    extend ActiveSupport::Concern

    using HTMLAttributesUtils

    MERGEABLE_ATTRIBUTES = [
      *HTMLAttributesUtils::DEFAULT_MERGEABLE_ATTRIBUTES,
      %i[data controller],
      %i[data action],
    ].freeze

    FLATTENABLE_ATTRIBUTES = [
      %i[data controller],
      %i[data action],
    ].freeze

    refine NilClass do
      def flatten_html(*)
        self
      end
    end

    refine Hash do
      def merge_html(attributes)
        result = deep_merge_html_attributes(attributes, mergeable_attributes: MERGEABLE_ATTRIBUTES)
        FLATTENABLE_ATTRIBUTES.each_with_object(result) do |path, flattened|
          flattened.flatten_html(*path)
        end
      end

      def flatten_html(key, *path)
        if path.empty?
          self[key] = self[key].join(" ") if self[key].is_a?(Array)
        else
          self[key].flatten_html(*path)
        end
      end
    end

    class_methods do
      using HasHtmlAttributes

      def define_html_attribute_methods(name, default: {})
        define_method("default_#{name}") { default }
        private("default_#{name}")

        define_method(name) do
          send("default_#{name}").merge_html(instance_variable_get("@#{name}") || {})
        end

        define_method("#{name}=") do |options|
          instance_variable_set("@#{name}", options.slice(:id, :aria, :class, :data).merge(options.fetch(:html, {})))
        end
      end
    end

    included do
      define_html_attribute_methods :html_attributes, default: {}
    end

    def initialize(**options)
      super(**options.except(:id, :aria, :class, :data, :html))

      self.html_attributes = options
    end
  end
end
