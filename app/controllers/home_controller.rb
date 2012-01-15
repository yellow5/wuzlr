class HomeController < ApplicationController
  
  layout "home"
  
  def index
    @leagues = LeagueStat.most_active_leagues
    @users = User.order('created_at DESC').limit(15)
    @dedicated = User.order('played DESC').limit(3)
  end
  
end
