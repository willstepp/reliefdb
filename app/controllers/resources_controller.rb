class ResourcesController < ApplicationController
  before_action :set_resource, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    f = Facility.find(params[:facility_id])
    if current_user && f.can_manage?(current_user)
      @resource = Resource.new
      @resource.facility = f
    else
      return redirect_to root_path, :alert => "You do not have permission to create a resource for this facility"
    end
  end

  def edit
    if !@resource.can_manage?(current_user)
      return redirect_to root_path, :alert => "You do not have permission to edit this resource"
    end
  end

  def create
    if !current_user
      return redirect_to root_path, :alert => "You do not have permission to create this resource"
    end

    @resource = Resource.new(resource_params)

    respond_to do |format|
      if @resource.save
        format.html { redirect_to facility_resource_path(@resource.facility, @resource), notice: 'Resource was successfully created.' }
        format.json { render action: 'show', status: :created, location: @resource }
      else
        format.html { render action: 'new' }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if !@resource.can_manage?(current_user)
      return redirect_to root_path, :alert => "You do not have permission to update this resource"
    end

    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to facility_resource_path(@resource.facility, @resource), notice: 'Resource was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if !@resource.can_manage?(current_user)
      return redirect_to root_path, :alert => "You do not have permission to delete this resource"
    end

    @resource.destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id], :include => :tags)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:description, :facility_id)
    end
end
