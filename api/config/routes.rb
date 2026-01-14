Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :users, only: [:create]
      post '/login', to: "authentication#login"
      post '/signup', to: "users#create"
    end
  end
end
