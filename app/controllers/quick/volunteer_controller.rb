class Quick::VolunteerController < ApplicationController

  layout 'general'

  def index
    redirect_to :action => 'categories'
  end

  def categories
    @items = Category.find(14).items
  end

  def list
    if params[:id]
      @item = Item.find(params[:id])
      @shelters = @item.shelters_that_need
    else
      @shelters = Category.find(14).shelters_that_need
    end
  end
end
