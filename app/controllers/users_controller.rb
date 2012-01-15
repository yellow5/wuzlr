class UsersController < ApplicationController

  def show
    @user         = User.find(params[:id])
    @user_leagues = @user.leagues
    @matches      = @user.matches.where(:state => 'recorded').order('finished_at DESC').limit(5)

    @nemesis      = @user.nemesis.first
    @nemesis      = {:user => @nemesis.first, :lost => @nemesis.last, :played => @user.number_matches_against( @nemesis.first )} if @nemesis

    @dream_team   = @user.dream_team.first
    @dream_team   = {:user => @dream_team.first, :won  => @dream_team.last, :played => @user.number_matches_with( @dream_team.first )} if @dream_team

    @walkover     = @user.walkovers.first
    @walkover     = {:user => @walkover.first, :won  => @walkover.last, :played => @user.number_matches_against( @walkover.first )} if @walkover

    @useless      = @user.useless_team.first
    @useless      = {:user => @useless.first, :lost  => @useless.last, :played => @user.number_matches_with( @useless.first )} if @useless

    respond_to do |format|
      format.html
    end
  end

  def compare
    @them           = User.find(params[:id])
    @their_matches  = @them.matches.where(:state => 'recorded')
    @you            = current_user
    @your_matches   = @you.matches.where(:state => 'recorded')
  end

private
  def league
    @league ||= League.find params[:league]
  end
end
