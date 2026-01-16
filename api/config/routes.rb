Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create, :index]
      post '/login', to: "authentication#login"
      post '/signup', to: "users#create"

      resources :messages, only: [:create, :index, :show]
    end
  end
end
