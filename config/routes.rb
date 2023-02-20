# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  devise_for :admins

  get 'home/index'

  resources :profile_admins
end
