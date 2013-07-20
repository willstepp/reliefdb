class ResourcesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @resource_pages, @resources = paginate :resource, :per_page => 10
  end

  def show
    @resource = Resource.find(params[:id])
  end

  def new
    @resource = Resource.new
  end

  def create
    @resource = Resource.new(params[:resource])
    if @resource.save
      flash[:notice] = 'Resource was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @resource = Resource.find(params[:id])
  end

  def update
    @resource = Resource.find(params[:id])
    if @resource.update_attributes(params[:resource])
      flash[:notice] = 'Resource was successfully updated.'
      redirect_to :action => 'show', :id => @resource
    else
      render :action => 'edit'
    end
  end

  def destroy
    Resource.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
