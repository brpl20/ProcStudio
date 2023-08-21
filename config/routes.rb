# frozen_string_literal: true

Rails.application.routes.draw do
  get '/api/v1/customer/document' => 'profile_customers#prepare_document'

  namespace :api do
    namespace :v1 do
      resources :profile_customers
      resources :offices
      resources :customers
      resources :powers
      resources :profile_admins
      resources :admins
      resources :works
      resources :jobs
      put '/external/login', to: 'auth#authenticate_with_token'
      post '/login', to: 'auth#authenticate'
      delete '/logout', to: 'auth#destroy'
    end
  end
end
