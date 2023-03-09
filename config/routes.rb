# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  get 'home/index'

  devise_for :admins
  devise_for :customers

  resources :people, controller: 'profile_customers', type: 'Person', only: [:new, :create]

  resources :offices
  resources :profile_admins
  resources :profile_customers
  resources :powers
end
