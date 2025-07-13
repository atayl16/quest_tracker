Rails.application.routes.draw do
  # Hotwire routes
  root "habits#index"
  resources :habits, only: [ :index ]

  # Future React routes (placeholder)
  # namespace :react do
  #   resources :habits, only: [:index]
  # end

  # Future API routes (placeholder)
  # namespace :api do
  #   namespace :v1 do
  #     resources :habits, only: [:index]
  #   end
  # end
end
