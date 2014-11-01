Rails.application.routes.draw do
  root to: 'main#index'

  devise_for :users
  
  constraints format: :json do
    get '/dashboard' => 'dashboard#show', as: :dashboard
    resources :sensors, only: [:show, :create, :update, :destroy]
  end
  
  get '/about' => 'main#index'
  get '/details/:sensor_id' => 'main#index'
end
