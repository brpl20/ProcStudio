# frozen_string_literal: true

Rails.application.routes.draw do
  get 'powers/index'
  root 'home#index'

  get 'home/index'

  devise_for :admins
  devise_for :customers

  resources :people, controller: 'profile_customers', type: 'People'
  resources :companies, controller: 'profile_customers', type: 'Companies'
  resources :accountings, controller: 'profile_customers', type: 'Accountings'
  resources :representatives, controller: 'profile_customers', type: 'Representatives'

  resources :offices
  resources :profile_admins
  resources :profile_customers
  resources :powers
end
