class ItemsController < ApplicationController

  include TableController
  helper :shelters

  #cache_sweeper :condition_sweeper, :only => [ :update ]
  #cache_sweeper :item_sweeper, :only => [ :create, :update, :destroy ]

  layout "general"

  def index
    list
    render :action => 'list'
  end

  def list    
    @title = "Items"
    store_location
    render :layout => 'reliefdb'
  end
  
  def expand    
    if request.xhr?
      cat = Category.find(params[:id])
      @items = Item.items_with_counts params[:id], (request.env["HTTP_USER_AGENT"].include?("MSIE") ? "DESC":"ASC")
      render :update do |page|
        page.select('.itemrow').each { |b| b.remove }
        page.insert_html :after,"cr#{params[:id]}", :partial => "item_detail", :collection => @items
      end
    else
      render :action => "list", :layout => 'reliefdb'     
    end
  end
  
  def self.default_hidecols
    [2,3,5,10]
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
    session[:list_type] = "item"
    filter_set_defaults(type = 'conditions')
    session[:filter][:item] = params[:id]
    redirect_to :controller => 'conditions', :action => 'list'    
  end

  def show_old
    @title = ""
    setup_table_vars
    cond, sort = condsort_from_params
    @item = Item.find(params[:id])
    @title = "Item: " + @item.name
    if cond
      cond[0] += " AND items.id = #{@item.id}"
    else
      cond = "items.id = #{@item.id}"
    end
    @condition_pages = Paginator.new self, Condition.count_ids_for(cond), 50, params['page']
    limit, offset = @condition_pages.current.to_sql
    @condition_ids = Condition.condition_ids_for(cond, sort, limit, offset)
    store_location
  end

  def new
    @item = Item.new
    @title = "New Item"
  end

  def create
    @item = Item.new(params[:item])
    pcategories = params[:categories] || []
    pcategories.each {|k, v|
      if v == "1"
        @item.categories << Category.find_by_id(k.to_i)
      end
    }
    @item.set_updated_by session['user']
    if @item.save
      flash[:notice] = 'Item was successfully created.'
      redirect_back_or_default :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @item = Item.find(params[:id])
    @title = "Edit Item: " + @item.name
  end

  def update
    @item = Item.find(params[:id])
    pcategories = params[:categories] || []
    categories = []
    pcategories.each {|k, v|
      if v == "1"
        categories << Category.find_by_id(k.to_i)
      end
    }
    params[:item][:categories] = categories
    @item.set_updated_by session['user']
    if @item.update_attributes(params[:item])
      flash[:notice] = 'Item was successfully updated.'
      redirect_back_or_default :action => 'show', :id => @item
    else
      render :action => 'edit'
    end
  end

  def destroy
    Item.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
