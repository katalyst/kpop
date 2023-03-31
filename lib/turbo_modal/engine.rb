# frozen_string_literal: true

require "rails"

module TurboModal
  class Engine < ::Rails::Engine
    config.autoload_once_paths = %W(#{root}/app/helpers)

    initializer "turbo_modal.helpers", before: :load_config_initializers do
      ActiveSupport.on_load(:action_controller_base) do
        helper TurboModal::Engine.helpers
      end

      ActiveSupport.on_load(:action_view_base) do
        helper TurboModal::Engine.helpers
      end
    end

    initializer "turbo_modal.assets" do
      config.after_initialize do |app|
        if app.config.respond_to?(:assets)
          app.config.assets.precompile += %w(turbo_modal.js)
        end
      end
    end

    initializer "turbo_modal.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
      end
    end
  end
end
