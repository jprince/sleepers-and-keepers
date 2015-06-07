Rails.application.routes.draw do
  devise_for :users
  root to: 'home#show'

  resources :leagues do
    resources :teams
    get 'draft',
      to: 'draft#show'
    get 'draft_order',
      to: 'draft_order#edit'
    post 'draft_order',
      to: 'draft_order#update'
  end
end
