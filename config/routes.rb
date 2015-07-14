Rails.application.routes.draw do
  devise_for :users
  root to: 'home#show'

  resources :leagues do
    resource :draft, only: :show
    resource :draft_results, only: [:create, :show]
    resource :keepers, only: [:create, :destroy, :edit]
    # workaround for PhantomJS bug https://github.com/ariya/phantomjs/issues/11214
    # league_manager_spec/can manage keepers after picks are generated will fail without this route
    delete '/keepers/edit', to: 'keepers#edit'
    resources :teams
    get 'draft_order',
      to: 'draft_order#edit'
    post 'draft_order',
      to: 'draft_order#update'
  end
end
