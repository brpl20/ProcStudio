# frozen_string_literal: true

Rails.application.routes.draw do
  root to: proc { [200, {}, ['API running']] }

  get '/api/v1/customer/document' => 'profile_customers#prepare_document'

  namespace :api do
    namespace :v1 do
      get '/offices/with_lawyers', to: 'offices#with_lawyers'
      resources :admins do
        collection do
          get :current
        end
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

      resources :profile_admins do
        collection do
          get :me
        end
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

      resources :zapsign, only: %i[create] do
        collection do
          post 'webhook'
        end
      end

      resources :office_types
      resources :powers
      
      # Team management routes
      resources :teams do
        member do
          post :add_member
          delete 'members/:admin_id', to: 'teams#remove_member'
          patch 'members/:admin_id', to: 'teams#update_member'
        end
        
        # Wiki routes nested under teams
        resources :wiki_pages do
          member do
            post :publish
            post :unpublish
            post :lock
            post :unlock
            get :revisions
            post :revert
          end
        end
        
        resources :wiki_categories
      end
      
      # Subscription management routes
      resources :subscriptions, only: %i[show create update] do
        collection do
          get :plans
          get :usage
        end
        member do
          patch :cancel
        end
      end

      post '/login', to: 'auth#authenticate'
      post '/register', to: 'registration#create'
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
    end
  end
end
