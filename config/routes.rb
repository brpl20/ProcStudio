# frozen_string_literal: true

Rails.application.routes.draw do
  get '/api/v1/customer/document' => 'profile_customers#prepare_document'

  namespace :api do
    namespace :v1 do
      get '/offices/with_lawyers', to: 'offices#with_lawyers'
      resources :admins
      resources :customers do
        member do
          post :resend_confirmation
        end
      end
      resources :jobs
      resources :offices
      resources :office_types
      resources :powers
      resources :profile_customers
      resources :profile_admins
      resources :works
      resources :work_events

      post '/login', to: 'auth#authenticate'
      delete '/logout', to: 'auth#destroy'

      namespace :customer do
        post :login, to: 'auth#authenticate'
        get :confirm, to: 'auth#confirm'
        post :password, to: 'auth#reset_password'
        put :password, to: 'auth#update_password'
        patch :password, to: 'auth#update_password'
        delete :logout, to: 'auth#destroy'

        resources :customers, only: %i[update show]
        resources :profile_customers, only: %i[update show]
        resources :works, only: %i[index show]
      end

      namespace :draft do
        resources :works
      end
    end
  end
end
