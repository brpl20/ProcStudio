# frozen_string_literal: true

Rails.application.routes.draw do
  # Admin
  post '/api/v1/auth/login', to: 'auth#authenticate'
  delete '/api/v1/auth/sign_out', to: 'admin/sessions#destroy'

  # Offices
  get '/api/v1/offices' => 'offices#index'

  resources :people, controller: 'profile_customers', type: 'People'
  resources :companies, controller: 'profile_customers', type: 'Companies'
  resources :accountings, controller: 'profile_customers', type: 'Accountings'
  resources :representatives, controller: 'profile_customers', type: 'Representatives'

  resources :profile_admins
  resources :profile_customers
  resources :powers
end
