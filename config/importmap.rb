# frozen_string_literal: true

pin_all_from Katalyst::Kpop::Engine.root.join("app/assets/javascripts/controllers"),
             under: "controllers",
             # preload in tests so that we don't start clicking before controllers load
             preload: Rails.env.test?
