# frozen_string_literal: true

Rails.application.routes.draw do
  get 'powers/index'
  root 'home#index'

  get 'home/index'

  devise_for :admins

  resources :profile_admins
  resources :offices
  resources :powers
end
