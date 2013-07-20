class FaqCategoriesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @faq_category_pages, @faq_categories = paginate :faq_category, :per_page => 10
  end

  def show
    @faq_category = FaqCategory.find(params[:id])
  end

  def new
    @faq_category = FaqCategory.new
  end

  def create
    @faq_category = FaqCategory.new(params[:faq_category])
    if @faq_category.save
      flash[:notice] = 'FaqCategory was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @faq_category = FaqCategory.find(params[:id])
  end

  def update
    @faq_category = FaqCategory.find(params[:id])
    if @faq_category.update_attributes(params[:faq_category])
      flash[:notice] = 'FaqCategory was successfully updated.'
      redirect_to :action => 'show', :id => @faq_category
    else
      render :action => 'edit'
    end
  end

  def destroy
    FaqCategory.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
