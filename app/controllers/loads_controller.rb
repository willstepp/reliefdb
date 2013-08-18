class LoadsController < ApplicationController

  include TableController
  helper :shelters

  layout 'general'

  #cache_sweeper :condition_sweeper, :only => [ :create, :update, :change_status ]

  def index
    list
    render :action => 'list'
  end

  def self.default_hidecols
    [3,4,6]
  end
  def self.tableid
    "load_list"
  end
  def self.hidecolname
    "loads_hidecols"
  end
  def self.cols
    Load::COLS
  end
  def self.sortclass
    Load
  end

  def list
    @title = "Loads"
    setup_table_vars
    cond, sort = condsort_from_params
    @records = Load.shelter_records_for(cond, sort)
    @shelter_ids = @records.map {|r| r['shelterid'].to_i }
    @controller = self
    store_location
  end
  
  def admin_list
    @loads = Load.where('status > 1000').order('status,updated_at desc')
  end

  def show
    @load = Load.find(params[:id])
    @title = "Load: #{@load.title}"
    @nextstatuses = @load.allowed_next_statuses(session['user'])
  end

  def new
    @title = "New load"
    @load = Load.new
    @load.source = Shelter.find(params[:srcid])
    if params[:dstid]
      @load.destination = Shelter.find(params[:dstid])
    else
      @load.destination = Condition.find(params[:dstcond]).shelter
      params[:dstid] = @load.destination.id
    end
    @load.transport_avail = 1
    @load.ready_by = Time.now
  end

  def create
    noerr = true
    @load = Load.new
    begin
      @load.source = Shelter.find(params[:srcid])
      @load.destination = Shelter.find(params[:dstid])
      @load.set_updated_by User.find(session['user'])
      @load.status = 0
      noerr = @load.update_attributes(params[:load])
      noerr && @load.update_sending(User.find(session['user']), params[:sending] || {})
    rescue ErrorAdded
      noerr = false
    end
    if noerr 
      flash[:notice] = 'Load was successfully created.'
      redirect_back_or_default :action => 'show', :id => @load
    else
      render :action => 'new'
    end
  end

  def edit
    @load = Load.find(params[:id])
    @title = "Edit Load: #{@load.title}"
  end

  def update
    noerr = true
    begin
      @load = Load.find(params[:id])
      @load.set_updated_by User.find(session['user'])
      noerr = @load.update_attributes(params[:load])
      noerr && (@load.status == 0) && @load.update_sending(User.find(session['user']), params[:sending] || {})
    rescue ErrorAdded
      noerr = false
    end
    if noerr 
      flash[:notice] = 'Load was successfully updated.'
      redirect_to :action => 'show', :id => @load
    else
      render :action => 'edit'
    end
  end

  def accept
    @load = Load.find(params[:id])
    if request.post?
      sending = params[:sending] || {}
      sending.keys.each do |i|
        if sending[i].to_i > @load.offer[i.to_i]
          flash[:notice] = "Error: can't accept more than was offered!"
          return
        end
      end
      @load.accept_with_sending(User.find(session['user']), sending)
      redirect_to :action => 'show', :id => @load
      return
    end
    @title = "Accepting Load To: #{@load.destination.name}"
  end

  def destroy
    Load.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def change_status
    @load = Load.find(params[:id])
    @newstat = params[:newstatus].to_i
    if @newstat != @load.status and @load.allowed_next_statuses(User.find(session['user'])).include?(@newstat)
      @load.move_to_status(User.find(session['user']), @newstat)
    end
    redirect_to :action => 'show', :id => params[:id]
  end

end
