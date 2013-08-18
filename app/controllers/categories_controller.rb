class CategoriesController < ApplicationController
  include TableController
  helper :shelters

  layout "general"

  def admin
    @categories = Category.all(:order => "upper(name)")
  end

  def index
    render :action => 'list', :layout => 'reliefdb'
  end

  def list
    @title = "Categories"
    @categories = Category.all(:order => "upper(name)")
    store_location
    render :layout => 'reliefdb'    
  end

  def self.default_hidecols
    [2,3,5]
  end
  def self.tableid
    "item_condition_list"
  end
  def self.hidecolname
    "item_conditions_hidecols"
  end
  def self.cols
    Condition::COLS
  end
  def self.sortclass
    Condition
  end

  def show
    session[:list_type] = "category"
    filter_set_defaults(type = 'conditions')
    session[:filter][:category] = params[:id]
    session[:filter][:item] = "All"
    redirect_to :controller => 'conditions', :action => 'list'
  end

  def show_old
    @title = ""
    setup_table_vars
    cond, sort = condsort_from_params
    @category = Category.find(params[:id])
    @title = "Category: " + @category.name
    @condition_pages = Paginator.new self, Condition.count_ids_for(cond, @category), 50, params['page']
    limit, offset = @condition_pages.current.to_sql
    @condition_ids = Condition.condition_ids_for(cond, sort, limit, offset, @category)
    store_location
  end

  def new
    @category = Category.new
    @title = "New Category"
  end

  def create
    @category = Category.new(params[:category])
    pitems = params[:items] || []
    pitems.each {|k, v|
      if v == "1"
        @category.items << Item.find(k.to_i)
      end
    }
    @category.set_updated_by User.find(session['user'])
    if @category.save
      flash[:notice] = 'Category was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @category = Category.find(params[:id])
    @title = "Edit Category: " + @category.name
  end

  def update
    @category = Category.find(params[:id])
    pitems = params[:items] || []
    items = []
    pitems.each {|k, v|
      if v == "1"
	items << Item.find(k.to_i)
      end
    }
    params[:category][:items] = items
    @category.set_updated_by User.find(session['user'])
    if @category.update_attributes(params[:category])
      flash[:notice] = 'Category was successfully updated.'
      redirect_back_or_default :action => 'show', :id => @category
    else
      render :action => 'edit'
    end
  end

  def destroy
    Category.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
