Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # User registration and profile routes
  resources :users, only: [ :new, :create, :show, :edit, :update ]

  # Radio hardware management
  resources :manufacturers
  resources :radio_models
  resources :codeplug_layouts

  # Networks and talkgroups
  resources :networks
  resources :talk_groups

  # Systems and infrastructure
  resources :systems do
    resources :system_talk_groups, only: [ :create, :destroy ]
  end

  # Standalone zones (new top-level resource)
  resources :zones, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    resources :zone_systems, only: [ :create, :destroy ] do
      resources :zone_system_talkgroups, only: [ :create, :destroy ]
    end
    member do
      patch :update_positions
    end
  end

  # Codeplugs and channels (nested)
  resources :codeplugs do
    member do
      post :generate_channels
    end
    # Add standalone zones to codeplugs
    resources :codeplug_zones, only: [ :create, :destroy ] do
      collection do
        patch :update_positions
      end
    end
    # Nested zones routes (kept for backward compatibility, will be deprecated)
    resources :zones do
      resources :channel_zones, only: [ :create, :destroy ]
      member do
        patch :update_positions
      end
    end
    resources :channels
  end

  # Static pages
  get "help", to: "pages#help"
  get "about", to: "pages#about"

  # Defines the root path route ("/")
  root "pages#home"
end
