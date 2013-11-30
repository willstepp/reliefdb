class HomeController < ApplicationController
  def index
    @orgs = Organization.all_approved.limit(100)
  end

  def dashboard
    @orgs = current_user.role?(:admin) ? Organization.all.limit(100) : current_user.organizations
  end
end
