Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users

      post 'auth/sign_in', to: 'authentication#sign_in'
      get 'auth/verify', to: 'authentication#verify_token'
      get 'auth/request', to: 'authentication#request_token'
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
