require_relative "../turbo_modal/version"

entry_path = case Rails.version[0].to_i
             when 6
               "app/javascripts/packs/application.js"
             when 7
               "app/javascripts/application.js"
             else
               exit "Turbo Modal requires rails 6 or higher"
             end

if Rails.root.join(entry_path).exist?
  say "Import Turbo Modal"
  append_to_file entry_path, %(import "@katalyst-interactive/turbo-modal"\n)
else
  say "You must import @katalyst-interactive/turbo-modal in your JavaScript entrypoint file", :red
end

say "Install Turbo Modal"
say "Turbo Modal #{TurboModal::VERSION} requires Stimulus@2.0.0", :yellow
run "yarn add @katalyst-interactive/turbo-modal"

append_to_file "app/javascript/controllers/index.js", %(\nimport { ScrimController, ModalController } from "@katalyst-interactive/turbo-modal"\n)
append_to_file "app/javascript/controllers/index.js", %(application.register("scrim", ScrimController)\n)
append_to_file "app/javascript/controllers/index.js", %(application.register("modal", ModalController)\n)
