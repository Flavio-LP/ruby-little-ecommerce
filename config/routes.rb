Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up: 200 if app, DB, and Redis are all reachable; 503 otherwise.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # Tenant-scoped routes: every seller's shop lives under its own slug.
  scope ":shop_slug" do
    namespace :admin do
      get "/", to: "dashboard#show", as: :dashboard
      resources :products, only: %i[index new create edit update] do
        patch :deactivate, on: :member
      end
    end

    resources :produtos, controller: "public/products", only: %i[index show] do
      post :add_to_cart, on: :member
    end

    resource :cart, controller: "public/carts", only: %i[show] do
      resources :cart_items, controller: "public/cart_items", only: %i[update destroy]
    end
  end
end
