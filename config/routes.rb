Reliefdb::Application.routes.draw do
  resources :items

  devise_for :users, :controllers => { :sessions => "sessions" }

  devise_scope :user do
    delete "/logout" => "devise/sessions#destroy"
    get "/logout" => "devise/sessions#destroy"
    get "/login" => "sessions#new", :as => :login
    get "/register" => "devise/registrations#new", :as => :register
  end

  mount RailsAdmin::Engine => '/admin', :as => 'admin'

  resources :categories
  resources :loads

  resources :organizations, :except => :index do
    resources :facilities, :except => :index

    delete "/remove_user/:user_id" => "organizations#remove_user", :as => :remove_user
    post "/add_user" => "organizations#add_user", :as => :add_user
  end

  resources :facilities, :except => :index do
    resources :resources, :except => :index
  end

  get "/dashboard" => "home#dashboard", :as => :dashboard

  root 'home#index'
end
