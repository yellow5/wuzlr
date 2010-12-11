ActionController::Routing::Routes.draw do |map|

  map.devise_for :users
  
  map.resource  :session, :only => [:new, :create, :destroy]
  
  map.root :controller => 'home'
  
  map.resources :leagues, :except => [:index, :destroy] do |league|
    league.resources :invites, :only   => [:new, :create]
    league.resources :matches, :except => [:index, :destroy], :member => {:full_time => :put}
  end
  
  map.resources :users, :only => [:new, :create], :member => {:compare => :get} do |user|
    user.resources :leagues, :only => :index
  end
  map.user "/users/:id", :controller => "users", :action => "show"
  
  map.league_graphs "/leagues/:league_id/graphs/:action", :controller => :graphs
  map.user_graphs   "/users/:user_id/graphs/:action",   :controller => :graphs
end
