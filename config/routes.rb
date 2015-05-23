Rails.application.routes.draw do
  devise_for :users
  root to: 'home#show'

  resources :leagues
end
