Rails.application.routes.draw do

  root "posts#top"
  get "/about" => "posts#about"

  devise_for :users
  resources :users, only: [:show, :edit, :update, :destroy]

  resources :post_categories, only: [:create, :show] do
    resource :favorite_categories, only: [:create, :destroy]
  end

  resources :posts do
    resource :post_comments, only: [:create, :destroy]
    resource :post_cheers, only: [:create, :destroy]
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
