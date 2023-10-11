Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resource :modal, only: [] do
    get :anonymous
    get :persistent
  end

  root to: "home#index"
end
