class FacilitiesController < ApplicationController
  before_action :set_facility, only: [:show, :edit, :update, :destroy]

  # GET /facilities/1
  # GET /facilities/1.json
  def show
  end

  # GET /facilities/new
  def new
    o = Organization.find(params[:organization_id])
    if current_user && o.can_manage?(current_user)
      @facility = Facility.new
      @facility.organization = o
    else
      return redirect_to root_path, :alert => "You do not have permission to create a facility for this organization"
    end
  end

  # GET /facilities/1/edit
  def edit
    if !@facility.can_manage?(current_user)
      return redirect_to root_path, :alert => "You do not have permission to edit this facility"
    end
  end

  # POST /facilities
  # POST /facilities.json
  def create
    if !current_user
      return redirect_to root_path, :alert => "You do not have permission to create this facility"
    end

    @facility = Facility.new(facility_params)

    respond_to do |format|
      if @facility.save
        format.html { redirect_to organization_facility_path(@facility.organization, @facility), notice: 'Facility was successfully created.' }
        format.json { render action: 'show', status: :created, location: @facility }
      else
        format.html { render action: 'new' }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /facilities/1
  # PATCH/PUT /facilities/1.json
  def update
    if !@facility.can_manage?(current_user)
      return redirect_to root_path, :alert => "You do not have permission to update this facility"
    end

    respond_to do |format|
      if @facility.update(facility_params)
        format.html { redirect_to organization_facility_path(@facility.organization, @facility), notice: 'Facility was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /facilities/1
  # DELETE /facilities/1.json
  def destroy
    if !@facility.can_manage?(current_user)
      return redirect_to root_path, :alert => "You do not have permission to delete this facility"
    end

    @facility.destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_facility
      @facility = Facility.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def facility_params
      params.require(:facility).permit(:website, :phone, :address, :headquarters, :contact_name, :twitter, :facebook, :organization_id)
    end
end
