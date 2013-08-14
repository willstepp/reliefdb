class SheltersController < ApplicationController
  include TableController

  #cache_sweeper :shelter_sweeper, :only => [ :update, :quickupdate ]
  #cache_sweeper :condition_sweeper, :only => [ :update, :quickupdate ]

  layout "general"

  def index
    list
    render :action => 'list'
  end

  def map
    if params[:mapshelters]
      @shelter_ids = params[:mapshelters].split('/').map {|i| i.to_i}
      @shelters = []
      for id in @shelter_ids
        @shelters << Shelter.find(id)
      end
      @markers = Shelter.markers_for(@shelters)
    elsif params[:map_shelter] and @shelter = Shelter.find(params[:map_shelter])
      @shelters = Shelter.where(:parish => @shelter.parish).order('catname(name)')
      @markers = Shelter.markers_for(@shelters, @shelter)
    elsif params[:mapconditions]
      @conditions = params[:mapconditions].split('/').map {|i| i.to_i}
      @shelters = @conditions.map {|c| Condition.find(c).shelter }
      @markers = Shelter.markers_for(@shelters)
    end
    render :layout => 'map'
  end
    
  def self.default_hidecols
    [11, 12, 13, 14]
  end
  def self.tableid
    "shelter_list"
  end
  def self.hidecolname
    "shelters_hidecols"
  end
  def self.cols
    ['Name', 'Org', 'Main Phone', 'State', 'Region', 'County', 'Town', 'Map', 'Status', 'Update', 'Cond Upd', 'Hours', 'Address', 'DC?', 'Space']
  end
  def self.sortclass
    Shelter
  end

  def list
    redirect_to :controller => 'facilities', :action => 'list'
  end
    
  def show
    begin
      @shelter = Shelter.find(params[:id])
    rescue
      flash[:notice] = "I Am Sorry, But That Is Not A Valid ID"
      redirect_to :controller => 'facilities', :action => 'list'
      return
    end
    @title = "Facility: " + @shelter.name
    @loads_in = Load.where("loads.destination_id = ? AND loads.status < 1000", @shelter.id).order('loads.id').include(:destination)
    @loads_out = Load.where("loads.source_id = ? AND loads.status < 1000", @shelter.id).order('loads.id').include(:source)
    store_location    
  end

  def new
    @shelter = Shelter.new
    @title = "New Facility"
    @shelter.status = 0
    @shelter.dc_more = 0
    @shelter.facility_type = 0
    @shelter.loading_dock = 0
    @shelter.forklift = 0
    @shelter.pallet_jack = 0
    @shelter.is_fee_required = "N/A"
    render :layout => 'reliefdb'
  end

  def create
    @shelter = Shelter.new()
    @shelter.set_updated_by session['user']
    @shelter.users << session['user']
    if @shelter.update_attributes(params[:shelter])
      flash[:notice] = 'Facility was successfully created.'
      redirect_to :action => 'show', :id => @shelter.id
    else
      render :action => 'new'
    end
  end

  def edit
    @shelter = Shelter.find(params[:id])
    @title = "Edit Facility: " + @shelter.name
    render :layout => 'reliefdb'
  end

  def update    
    @shelter = Shelter.find(params[:id])
    @shelter.set_updated_by session['user']
    if @shelter.update_attributes(params[:shelter])
      flash[:notice] = 'Facility was successfully updated.'
      redirect_to :action => 'show', :id => @shelter
    else
      render :action => 'edit', :retry => true
    end
  end

  def quickedit
    if params[:checkalltype]
      if params[:checkalltype] == 'surplus'
        @checkallsurplus = params[:checkall]
      else
        @checkallneeds = params[:checkall]
      end
    end
    @shelter = Shelter.find(params[:id])
    @needs = Need.where(:shelter_id => @shelter.id).order('upper(items.name)').include(:item)
    @surpluses = Surplus.where(:shelter_id => @shelter.id).order('upper(items.name)').include(:item)
    session['quick-edits'] = {}
    @needs.each {|n| session['quick-edits'][n.id] = n}
    @surpluses.each {|n| session['quick-edits'][n.id] = n}
    @title = "Quick Edit: " + @shelter.name
    render :layout => 'reliefdb'
  end

  def quickupdate
    @shelter = Shelter.find(params[:id])
    @shelter.update_cond(session['user'])
    params[:conditions].each do |id, condattrs|
      begin
        condition = Condition.find(id)
      rescue
        next
      end
      if not @shelter.conditions.include?(condition)
        next
      end
      # Since we know it's our condition, we can assume permission issues were handled correctly
      # via shelter controller/action checking
      if condattrs[:delete]
        condition.destroy()
      else
        if session['quick-edits'] and oldcond = session['quick-edits'][id.to_i]
          oldattrs = oldcond.attributes
          oldcond.attributes = condattrs
            if oldcond.attributes == oldattrs
              next
            end
        end
        condition.set_updated_by session['user']
        if condition.update_attributes(condattrs)
          flash[:notice] = 'Condition was successfully updated.'
        else
          flash[:notice] = 'Error updating conditions.'
          redirect_to :action => 'show', :id => @shelter
          return
        end
      end
    end
    session['quick-edits'] = nil
    redirect_to :action => 'show', :id => @shelter
  end

  def destroy
    Shelter.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def calculate_locations
    Shelter.where(:latitude => nil).each do |s|
      s.update_address
      if s.latitude
	ActiveRecord::Base.connection.update("UPDATE shelters SET latitude = #{s.latitude}, longitude = #{s.longitude} WHERE id = #{s.id};")
      end
    end
  end

end
