Rails.application.routes.draw do
  resources :accounts
  resources :sales
  resources :claims
  resources :orders do
    member do
      get 'approve'
      get 'reject'
    end
  end
  mount RailsAdmin::Engine => '/fapp', as: 'rails_admin'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  root to: "home#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
