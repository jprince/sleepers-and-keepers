Rails.application.routes.draw do
  devise_for :users
  root to: 'home#show'

  resources :leagues do
    resource :draft, only: :show
    resource :draft_results, only: [:create, :show]
    resource :keepers, only: [:create, :edit]
    resources :teams
    get 'draft_order',
      to: 'draft_order#edit'
    post 'draft_order',
      to: 'draft_order#update'
  end
end
