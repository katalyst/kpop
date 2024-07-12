# frozen_string_literal: true

require "rails/engine"
require "turbo-rails"

module Katalyst
  module Kpop
    class Engine < ::Rails::Engine
      isolate_namespace Katalyst::Kpop
      config.eager_load_namespaces << Katalyst::Kpop
      config.autoload_once_paths = %W(
        #{root}/app/helpers
        #{root}/app/controllers
        #{root}/app/controllers/concerns
      )
      config.paths.add("lib", autoload_once: true)

      initializer "kpop.assets" do
        config.after_initialize do |app|
          if app.config.respond_to?(:assets)
            app.config.assets.precompile += %w(katalyst-kpop.js)
          end
        end
      end

      initializer "kpop.helpers", before: :load_config_initializers do
        ::Turbo::Streams::TagBuilder.define_method(:kpop) do
          Katalyst::Kpop::Turbo::TagBuilder.new(self)
        end

        ActiveSupport.on_load(:action_controller_base) do
          include Katalyst::Kpop::FrameRequest
          helper Katalyst::Kpop::Engine.helpers
        end
      end

      initializer "kpop.importmap", before: "importmap" do |app|
        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << root.join("config/importmap.rb")
          app.config.importmap.cache_sweepers << root.join("app/assets/builds")
        end
      end

      initializer "kpop.rspec" do
        next unless defined?(RSpec) && RSpec.respond_to?(:configure)

        RSpec.configure do |config|
          config.include Katalyst::Kpop::Matchers, type: :component
          config.include Katalyst::Kpop::Matchers, type: :request
        end
      end
    end
  end
end
