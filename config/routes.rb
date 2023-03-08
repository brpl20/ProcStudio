# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :customers
  root 'home#index'

  get 'home/index'

  devise_for :admins

  resources :profile_admins
  resources :offices
end
