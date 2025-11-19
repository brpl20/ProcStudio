# frozen_string_literal: true

require 'sidekiq/web' if defined?(Sidekiq)

Rails.application.routes.draw do
  # Mount Action Cable for WebSocket connections
  mount ActionCable.server => '/cable'

  # Mount Sidekiq Web UI (only in development/staging, protect in production)
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development? || Rails.env.staging?

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

      resources :notifications do
        member do
          patch :mark_as_read
          patch :mark_as_unread
        end

        collection do
          patch :mark_all_as_read
          get :unread_count
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
          post :upload_attachment
          delete 'attachments/:attachment_id', action: :remove_attachment
        end

        resources :comments, controller: 'job_comments', only: [:index, :create, :update, :destroy]
      end

      resources :offices do
        member do
          post :restore
          post :upload_logo
          post :upload_contracts
          delete 'attachments/:attachment_id', action: :remove_attachment
          patch 'attachments/metadata', action: :update_attachment_metadata
        end

        collection do
          get :with_lawyers
        end
      end

      resources :profile_customers do
        member do
          post :restore
        end

        # Nested represents routes for a specific customer
        resources :represents, only: [:index, :create]
      end

      # Direct represents routes for team-wide operations
      resources :represents, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :deactivate
          post :reactivate
        end

        collection do
          get 'by_representor/:representor_id', to: 'represents#by_representor'
        end
      end

      resources :drafts, only: [:index, :show, :create, :update, :destroy] do
        collection do
          post :save # Keep for backwards compatibility
        end
        member do
          post :recover
          patch :fulfill
        end
      end

      resources :user_profiles do
        member do
          post :restore
          post :upload_avatar
        end

        collection do
          post :complete_profile
        end
      end

      resources :works do
        member do
          post :restore
          post :convert_documents_to_pdf
          post :upload_document
          delete 'documents/:document_id', action: :remove_document
        end

        resources :documents, only: [:update]

        # New nested routes for procedures
        resources :procedures do
          member do
            get :financial_summary
          end

          collection do
            get :tree
          end

          # Child procedures
          post :create_child, on: :member

          # Procedural parties management
          resources :procedural_parties do
            member do
              post :set_primary
            end

            collection do
              put :reorder
            end
          end

          # Procedure-specific honoraries
          resources :honoraries do
            member do
              get :summary
            end

            resources :components, controller: 'honorary_components' do
              member do
                post :toggle_active
                get :calculate
              end

              collection do
                put :reorder
              end
            end

            resource :legal_cost, only: [:show, :create, :update, :destroy] do
              member do
                get :summary
                get :overdue_entries
                get :upcoming_entries
              end

              resources :entries, controller: 'legal_cost_entries' do
                member do
                  post :mark_as_paid
                  post :mark_as_unpaid
                end

                collection do
                  post :batch_create
                  get :by_type
                end
              end
            end
          end
        end

        # Work-level (global) honoraries
        resources :honoraries do
          member do
            get :summary
          end

          resources :components, controller: 'honorary_components' do
            member do
              post :toggle_active
              get :calculate
            end

            collection do
              put :reorder
            end
          end

          resource :legal_cost, only: [:show, :create, :update, :destroy] do
            member do
              get :summary
              get :overdue_entries
              get :upcoming_entries
            end

            resources :entries, controller: 'legal_cost_entries' do
              member do
                post :mark_as_paid
                post :mark_as_unpaid
              end

              collection do
                post :batch_create
                get :by_type
              end
            end
          end
        end
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

      # Current user endpoints
      get '/whoami', to: 'current_user#whoami'
      get '/user_info/:identifier', to: 'current_user#user_info'
      get '/user_by_profile/:profile_id', to: 'current_user#user_by_profile'
      get '/user_by_id/:user_id', to: 'current_user#user_by_id'

      # Mirror auth routes (redirect to main login)
      namespace :auth do
        post '/login', to: redirect('/api/v1/login')
      end

      # Test route
      get '/test', to: 'test#index'

      # Health check route (redirects to test)
      get '/health', to: redirect('/api/v1/test')

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
