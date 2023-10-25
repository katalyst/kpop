# frozen_string_literal: true

require "rails"
require "turbo-rails"

module Katalyst
  module Kpop
    class Engine < ::Rails::Engine
      config.autoload_once_paths = %W(#{root}/app/helpers)

      PRECOMPILE_ASSETS = %w(kpop.js kpop.min.js kpop.min.js.map).freeze

      initializer "kpop.assets" do
        if Rails.application.config.respond_to?(:assets)
          Rails.application.config.assets.precompile += PRECOMPILE_ASSETS
        end
      end

      initializer "kpop.helpers", before: :load_config_initializers do
        ::Turbo::Streams::TagBuilder.define_method(:kpop) do
          Katalyst::Kpop::Turbo::TagBuilder.new(self)
        end

        ActiveSupport.on_load(:action_controller_base) do
          helper Katalyst::Kpop::Engine.helpers
        end
      end

      initializer "kpop.importmap", before: "importmap" do |app|
        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << root.join("config/importmap.rb")
          app.config.importmap.cache_sweepers << root.join("app/assets/builds")
        end
      end
    end
  end
end
