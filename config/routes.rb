# frozen_string_literal: true

Rails.application.routes.draw do
  root to: proc { [200, {}, ['API running']] }

  get '/api/v1/customer/document' => 'profile_customers#prepare_document'

  namespace :api do
    namespace :v1 do
      resources :law_areas
      # Public routes (no authentication required)
      namespace :public do
        post 'user_registration', to: 'user_registration#create'
      end

      get '/offices/with_lawyers', to: 'offices#with_lawyers'
      resources :users do
        member do
          post :restore
        end
      end

      resources :customers do
        member do
          post :resend_confirmation
          post :restore
        end
      end

      resources :jobs do
        member do
          post :restore
        end
      end

      resources :offices do
        member do
          post :restore
        end
      end

      resources :profile_customers do
        member do
          post :restore
        end
      end

      resources :user_profiles do
        member do
          post :restore
        end
      end

      resources :works do
        member do
          post :restore
          post :convert_documents_to_pdf
        end

        resources :documents, only: [:update]
      end

      resources :work_events do
        member do
          post :restore
        end
      end

      namespace :draft do
        resources :works do
          member do
            post :restore
          end
        end
      end

      resources :zapsign, only: [:create] do
        collection do
          post 'webhook'
        end
      end

      resources :office_types
      resources :powers
      resources :teams

      # My Team routes
      get 'my_team', to: 'my_team#show'
      put 'my_team', to: 'my_team#update'
      patch 'my_team', to: 'my_team#update'
      get 'my_team/members', to: 'my_team#members'

      post '/login', to: 'auth#authenticate'
      delete '/logout', to: 'auth#destroy'

      namespace :customer do
        post :login, to: 'auth#authenticate'
        get :confirm, to: 'auth#confirm'
        post :password, to: 'auth#reset_password'
        put :password, to: 'auth#update_password'
        patch :password, to: 'auth#update_password'
        delete :logout, to: 'auth#destroy'

        resources :customers, only: [:update, :show]
        resources :profile_customers, only: [:update, :show]
        resources :works, only: [:index, :show]
      end
    end
  end
end
