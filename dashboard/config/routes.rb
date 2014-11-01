Rails.application.routes.draw do
  root to: 'main#index'

  devise_for :users

  constraints format: :html do
    get '/settings' => 'main#index'
    get '/about' => 'main#index'
  end

  constraints format: :json do
    get '/dashboard' => 'dashboard#show', as: :dashboard
    resources :sensors, only: [:index, :create, :update, :destroy]
  end
end
