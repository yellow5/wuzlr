class LeaguesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:new, :create]
  
  # GET /leagues
  def index
  end
  
  # GET /leagues/1
  def show
    @league     = League.find(params[:id])
    @subheader  = "Current standings"
    @stats      = @league.stats.order('win_percent DESC').includes(:user)
    @matches    = @league.matches.where(:state => 'recorded').order('finished_at ASC').limit(3)
    @fifa_teams = FifaTeam.order('goals_for DESC')
  end

  # GET /leagues/new
  def new
    @league = League.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /leagues/1/edit
  def edit
    @league = League.find(params[:id])
  end

  # POST /leagues
  def create
    @league       = League.new(params[:league])
    @league.user  = current_user
    
    respond_to do |format|
      if @league.save
        @league.add_player current_user
        if !!params[:demo_users]
          ["sayhello@petercolesdc.com", "jamie.dyer@jivatechnology.com", "theo.cushion@jivatechnology.com"].each {|e|
            u = User.find_by_email(e)
            puts u.inspect
            @league.add_player u if u
          }
        end        
        flash[:notice] = 'League was successfully created.'
        format.html { redirect_to(@league) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /leagues/1
  def update
    @league = League.find(params[:id])

    respond_to do |format|
      if @league.update_attributes(params[:league])
        flash[:notice] = 'League was successfully updated.'
        format.html { redirect_to(@league) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
end
