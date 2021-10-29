module TurboModal
  class Engine < ::Rails::Engine
    config.autoload_once_paths = %W(#{root}/app/helpers)

    PRECOMPILE_ASSETS = %w( turbo_modal.css )

    initializer "turbo_modal.assets" do
      if Rails.application.config.respond_to?(:assets)
        Rails.application.config.assets.precompile += PRECOMPILE_ASSETS
      end
    end

    initializer "turbo_modal.helpers", before: :load_config_initializers do
      ActiveSupport.on_load(:action_controller_base) do
        helper TurboModal::Engine.helpers
      end

      ActiveSupport.on_load(:action_view_base) do
        helper TurboModal::Engine.helpers
      end
    end
  end
end
