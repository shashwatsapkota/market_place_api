require 'api_constraints'
Rails.application.routes.draw do
  devise_for :users, path: 'u'
  namespace :api, defaults: { format: :json }, path: '/' do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :users, only: %i[show create update destroy] do
        resources :products, only: %i[create update destroy]
      end
      resources :sessions, only: %i[create destroy]
      resources :products, only: %i[show index]
    end
  end
end
