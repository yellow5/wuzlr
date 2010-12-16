# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  layout "default"
  
  before_filter :leagues, :wup_wup_playaz
  
  def leagues
    @leagues = current_user.leagues if user_signed_in?
  end
  
  def wup_wup_playaz
    @wup_wup_playaz = User.wup_wup_playaz
  end
end
