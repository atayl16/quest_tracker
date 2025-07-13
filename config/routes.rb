Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication routes
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  get "/signin", to: "sessions#new"
  post "/signin", to: "sessions#create"
  delete "/signout", to: "sessions#destroy"

  root "habits#index"
  resources :habits, only: [ :index ] do
    resources :check_ins, only: [ :create ]
  end
end
