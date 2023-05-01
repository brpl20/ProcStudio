# frozen_string_literal: true

Rails.application.routes.draw do
  # Admin
  post '/api/v1/auth/login', to: 'auth#authenticate'
  delete '/api/v1/auth/logout', to: 'auth#destroy'

  get '/api/v1/offices' => 'offices#index'
  get '/api/v1/customers' => 'profile_customers#index'
  get '/api/v1/customers/:id' => 'profile_customers#show'
  get '/api/v1/admins' => 'profile_admins#index'
  get '/api/v1/admins/:id' => 'profile_admins#show'

  get '/api/v1/customer/document' => 'profile_customers#prepare_document'

  post 'api/v1/offices' => 'offices#new_office'

  resources :people, controller: 'profile_customers', type: 'People'
  resources :companies, controller: 'profile_customers', type: 'Companies'
  resources :accountings, controller: 'profile_customers', type: 'Accountings'
  resources :representatives, controller: 'profile_customers', type: 'Representatives'

  resources :profile_admins
  # resources :profile_customers
  resources :powers
end
