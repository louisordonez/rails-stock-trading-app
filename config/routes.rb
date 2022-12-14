Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Authentication
      get 'auth/check', to: 'authentication#check_role'

      post 'auth/sign_in', to: 'authentication#sign_in'
      get 'auth/verify', to: 'authentication#verify_email'
      get 'auth/request', to: 'authentication#request_email_token'

      patch 'auth/trade/:id', to: 'authentication#verify_trade'

      # Users
      post 'users', to: 'users#create_user'

      get 'users/show', to: 'users#show_current'
      patch 'users/update', to: 'users#update_current'
      delete 'users/destroy', to: 'users#destroy_current'

      post 'users/admin', to: 'users#create_admin'
      get 'users/all', to: 'users#index'
      get 'users/show/:id', to: 'users#show_user'
      patch 'users/update/:id', to: 'users#update_user'
      delete 'users/destroy/:id', to: 'users#destroy_user'

      # Wallets
      get 'wallets', to: 'wallets#show'
      post 'wallets/deposit', to: 'wallets#deposit'
      post 'wallets/withdraw', to: 'wallets#withdraw'

      get 'wallets/:id', to: 'wallets#show_wallet'

      # Stocks
      get 'stocks', to: 'stocks#info'
      post 'stocks/buy', to: 'stocks#buy'
      post 'stocks/sell', to: 'stocks#sell'

      get 'stocks/most_active', to: 'stocks#most_active'
      get 'stocks/symbols', to: 'stocks#get_symbols'

      # Transactions
      get 'transactions', to: 'transactions#user_index'

      get 'transactions/all', to: 'transactions#admin_index'
      get 'transactions/:id', to: 'transactions#show_index'

      # Routes
      get 'portfolios', to: 'portfolios#show'
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
