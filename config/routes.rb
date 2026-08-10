Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/#{Tenant::DEFAULT_TENANT}")

  resources :products
  resources :orders, only: %i[index new create show]

  get ":tenant_name", to: "tenants#show", as: :tenant

  devise_for :users, controllers: {
    registrations: "registrations",
    sessions: "sessions"
  }, skip: %i[registrations sessions]

  devise_scope :user do
    get ":tenant_name/users/sign_in", to: "sessions#new", as: :new_user_session
    post ":tenant_name/users/sign_in", to: "sessions#create", as: :user_session
    delete ":tenant_name/users/sign_out", to: "sessions#destroy", as: :destroy_user_session
    get ":tenant_name/users/sign_up", to: "registrations#new", as: :new_user_registration
    post ":tenant_name/users", to: "registrations#create", as: :user_registration
  end
end
