Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resource :modal, only: %i[update] do
    get :anonymous
    get :persistent
  end

  get "/test", to: "home#test"

  root to: "home#index"
end
