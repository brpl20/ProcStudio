# frozen_string_literal: true

Rails.application.routes.draw do
  # get '/api/v1/customers' => 'profile_customers#index'
  # get '/api/v1/customers/:id' => 'profile_customers#show'

  get '/api/v1/admins' => 'profile_admins#index'
  get '/api/v1/admins/:id' => 'profile_admins#show'

  get '/api/v1/customer/document' => 'profile_customers#prepare_document'

  namespace :api do
    namespace :v1 do
      resources :profile_customers
      resources :offices
      resources :customers
      post '/login', to: 'auth#authenticate'
      delete '/logout', to: 'auth#destroy'
    end
  end
end
