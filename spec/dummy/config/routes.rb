# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resource :modal, only: %i[show update]

  get "/test", to: "home#test"
  get "/redirect", to: "home#redirect"

  resource :parent, only: :show do
    resources :children, only: %i[new create]
  end

  root to: "home#index"
end
