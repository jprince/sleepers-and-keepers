Rails.application.routes.draw do
  require 'sidekiq/web'

  devise_for :users
  root to: 'home#show'

  resources :leagues do
    resource :draft, only: :show
    resource :draft_picks, only: [:create, :destroy, :edit, :update]
    resource :draft_results, only: [:create, :show]
    resource :keepers, only: [:create, :destroy, :edit]
    resources :teams
    get 'draft_order',
      to: 'draft_order#edit'
    post 'draft_order',
      to: 'draft_order#update'
  end

  # Serve websocket cable requests in-
  mount ActionCable.server => '/cable'

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
end
