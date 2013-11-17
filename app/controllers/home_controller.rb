class HomeController < ApplicationController
  def index
    if signed_in?
      render 'dashboard' and return
    end
  end

  def dashboard
  end
end
