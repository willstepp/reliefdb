class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show, :edit, :update, :destroy]

  # GET /organizations
  # GET /organizations.json
  def index
    @organizations = Organization.all_approved
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
  end

  # GET /organizations/new
  def new
    if current_user
      @organization = Organization.new
    else
      return redirect_to root_path, :alert => "You do not have permission to create an organization"
    end
  end

  # GET /organizations/1/edit
  def edit
    if !@organization.can_manage?(current_user)
      return redirect_to root_path, :alert => "You do not have permission to edit this organization"
    end
  end

  # POST /organizations
  # POST /organizations.json
  def create
    if !current_user
      return redirect_to root_path, :alert => "You do not have permission to create this organization"
    end

    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        current_user.organizations << @organization

        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render action: 'show', status: :created, location: @organization }
      else
        format.html { render action: 'new' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    if !@organization.can_manage?(current_user)
      return redirect_to root_path, :alert => "You do not have permission to update this organization"
    end

    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    if !@organization.can_manage?(current_user)
      return redirect_to root_path, :alert => "You do not have permission to delete this organization"
    end

    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:name, :email, :phone)
    end
end
