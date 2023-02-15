Rails.application.routes.draw do
  devise_for :admins
  get 'home/index'
  root 'home#index'
end
