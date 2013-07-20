class FaqEntriesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @faq_entry_pages, @faq_entries = paginate :faq_entry, :per_page => 10, :order_by => 'position'
  end

  def show
    @faq_entry = FaqEntry.find(params[:id])
  end

  def up
    @faq_entry = FaqEntry.find(params[:id])
    @faq_entry.move_higher
    redirect_to :action => 'list'
  end

  def down
    @faq_entry = FaqEntry.find(params[:id])
    @faq_entry.move_lower
    redirect_to :action => 'list'
  end

  def new
    @faq_entry = FaqEntry.new
  end

  def create
    @faq_entry = FaqEntry.new(params[:faq_entry])
    if @faq_entry.save
      flash[:notice] = 'FaqEntry was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @faq_entry = FaqEntry.find(params[:id])
  end

  def update
    @faq_entry = FaqEntry.find(params[:id])
    if @faq_entry.update_attributes(params[:faq_entry])
      flash[:notice] = 'FaqEntry was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    FaqEntry.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
