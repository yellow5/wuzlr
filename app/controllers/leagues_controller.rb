class LeaguesController < ApplicationController
  
  before_filter :authenticate, :only => [:new, :create]
  # before_filter :is_owner?, :only => [:edit, :update]
  
  # GET /leagues/1
  def show
    @league = League.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
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
