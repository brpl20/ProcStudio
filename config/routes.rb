# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  get 'home/index'

  devise_for :admins
  devise_for :customers

  resources :offices
  resources :profile_admins
  resources :powers
end
