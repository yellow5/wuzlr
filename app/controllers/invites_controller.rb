class InvitesController < ApplicationController
  before_filter :authenticate_user!

  def new
    league
  end

  def create
    league
    params[:emails].each do |email|
      if user = User.find_by_email(email)
        @league.add_player user
      else
        Mailer.invitation(email, @league).deliver unless email.blank?
      end
    end
    flash[:success] = "Invites have been sent"
    redirect_to league_url(@league)
  end

  private
    def league
      @league = League.find(params[:league_id])
    end
end
