Wuzlr::Application.routes.draw do
  devise_for :users
  root :to => 'home#index'

  resources :leagues, :except => [:index, :destroy] do
    resources :invites, :only => [:new, :create]
    resources :matches, :except => [:index, :destroy] do
      member do
        put :full_time
      end
    end
  end

  resources :users, :only => [:new, :create] do
    member do
      get :compare
    end
    resources :leagues, :only => :index
  end

  match '/users/:id' => 'users#show', :as => :user
  match '/leagues/:league_id/graphs/:action' => 'graphs#index', :as => :league_graphs
  match '/users/:user_id/graphs/:action' => 'graphs#index', :as => :user_graphs
end
