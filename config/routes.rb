Rails.application.routes.draw do
  # articles (for commonplace)
  get "/articles/admin", to: "articles#admin_index", as: :admin_articles
  resources :articles

  # newsletters (a type of article)
  post "/newsletters/send/:id", to: "newsletters#send_mail", as: "send_newsletter"
  resources :newsletters, only: [ :index, :show ]

  # spotlights (a type of article)
  resources :spotlights, only: [ :index, :show, :edit, :update ]

  # subscribers
  get "subscriber/confirm", to: "subscribers#confirm", as: "confirm_subscriber"
  resources :subscribers, only: [ :new, :create ]

  # dashboard
  get "dashboard", to: "dashboard#commissions"
  get "dashboard/settings"
  get "dashboard/commissions"
  get "dashboard/commission/:id", to: "dashboard#commission", as: "dashboard_commission"

  # ADMIN
  namespace :admin do
    resources :artists, only: [ :index, :update ]
    resources :artist_drafts, only: [ :index ]
    resources :users, only: [ :index ]
    resources :subscribers, only: [ :index, :show, :destroy ] do
      post "invite", on: :member
    end
    resources :tags, except: [ :show ]

    # dashboard (non resourceful)
    get "dashboard/patrons"
    get "dashboard/artists"
    get "dashboard/tags"
    get "dashboard/subscribers"
    get "dashboard/articles"
    get "dashboard/newsletters"
    get "dashboard/spotlights"
  end

  # users
  resources :users, only: [ :edit, :update ] do
    member do
      get "edit_profile_image"
      patch "edit_profile_image", to: "users#update_profile_image"
      get "verify_email"
      post "resend_verification_email"
    end

    resources :commissions, only: [ :index ]

    scope module: "users" do
      resource :newsletter_subscription, only: [ :edit, :update ]
      resource :setting, only: [ :edit, :update ]
    end
  end

  resources :commissions, only: [ :show ] do
    resources :messages, module: :commission, shallow: true, only: [ :index, :show, :create, :edit, :update, :destroy ]
  end
  resources :commission_requests, only: [ :new, :create ]

  # artists
  resources :artists, only: [ :show, :edit, :update ] do
    member do
      get "edit_settings"
    end

    scope module: "artists" do
      resources :commission_types, except: [ :show ]
      resources :artworks, except: [ :new ]
      resources :taggings, only: [ :index, :create, :destroy ]
    end
  end

  namespace :artist do
    resources :incoming_commissions, only: [ :index ] do
      member do
        post "accept"
        post "decline"
      end
    end

    # non resourceful dashboard stuff
    get "dashboard/profile"
    get "dashboard/gallery"

    # non resourceful atelier stuff
    get "atelier", to: "atelier#home"
    get "atelier/incoming_commissions"
    get "atelier/active_commissions"
    get "atelier/commission/:id", to: "atelier#commission", as: :atelier_commission
    get "atelier/finished_commissions"
  end

  resources :artist_registrations, only: [ :new, :create ]
  resources :artist_drafts, only: [ :show, :destroy ] do
    get "not_found", on: :collection, as: :not_found
    member do
      get "convert"
    end
  end

  # pages
  get "privacy-policy", to: "pages#privacy_policy"
  root to: "pages#index"

  # session
  resource :session
  get "login", to: "sessions#new", as: "login"

  # not allowing resgistration atm
  # resource :registration, only: %i[new create]
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # dev only stuff
  if Rails.env.development? or ENV["DEPLOYMENT_ENVIRONMENT"] != "prod"
    get "ui-showcase", to: "pages#ui_showcase"
  end
end
