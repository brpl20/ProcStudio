# frozen_string_literal: true

Rails.application.routes.draw do
  get '/api/v1/customer/document' => 'profile_customers#prepare_document'

  namespace :api do
    namespace :v1 do
      get '/offices/with_lawyers', to: 'offices#with_lawyers'
      resources :admins
      resources :customers
      resources :jobs
      resources :offices
      resources :office_types
      resources :powers
      resources :profile_customers
      resources :profile_admins
      resources :works
      post '/login', to: 'auth#authenticate'
      delete '/logout', to: 'auth#destroy'

      namespace :draft do
        resources :works
      end
    end
  end
end
