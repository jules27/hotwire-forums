Rails.application.routes.draw do
  resources :categories
  devise_for :users
  root to: "main#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :discussions do
    resources :posts, module: :discussions

    collection do
      get 'category/:id', to: "categories/discussions#index", as: :category
    end

    resources :notifications, only: :create, module: :discussions
  end

  resources :notifications, only: :index do
    collection do
      post '/mark_as_read', to: "notifications#read_all", as: :read
    end
  end
end
