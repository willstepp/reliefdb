class HomeController < ApplicationController
  def index
    @orgs = Organization.all_approved
  end

  def dashboard
    @orgs = current_user.role?(:admin) ? Organization.all : current_user.organizations
  end
end
