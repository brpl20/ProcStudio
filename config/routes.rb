# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :customers
  root 'home#index'
  devise_for :admins

  get 'home/index'

  resources :profile_admins
end
