class ConditionsController < ApplicationController

  include TableController
  helper :shelters

  #cache_sweeper :shelter_sweeper, :only => [ :create, :update, :destroy ]
  #cache_sweeper :condition_sweeper, :only => [ :update, :destroy ]

  layout "general" 

  def index
    list
    render :action => 'list'
  end

  def self.default_hidecols
    [2,3,12]
  end
  def self.tableid
    "condition_list"
  end
  def self.hidecolname
    "conditions_hidecols"
  end
  def self.cols
    Condition::COLS
  end
  def self.sortclass
    Condition
  end

  def default_sort_name
    "Update"
  end
#-----old code above this line/new code below this line-----------------------------------------------------
  def filter
    flash.keep
    filter_set_defaults('conditions')    
    render :layout => "reliefdb"
  end  

  def filter_set  
    session[:list_type] = "conditions"
    if params[:commit] == 'Load' || params[:commit]=='Go'
        srch = Search.find(params[:update_id])
        session[:filter] = srch.save_data
        redirect_to :action => 'filter' if params[:commit]=='Load'
        redirect_to :action => 'list' if params[:commit]=='Go'
    else
      filter_set_all
      if flash[:filter_error]
        flash[:notice] = flash[:filter_error]
        redirect_to :action => 'filter'
      else
        redirect_to :action => 'list'
      end
    end
  end

  def listall
    session[:filter][:item] = nil if session[:list_type] == "item"
    session[:filter][:category] = nil if session[:list_type] == "category"
    session[:list_type] = "conditions"
    list
  end

  def list   
    if params[:preset]
      begin
        srch = Search.find(params[:preset])
      rescue
      flash[:notice] = "Either Your Request Was Invalid or That Search Has Been Removed"
        redirect_to :action => 'filter'
        return
      end
      session[:filter] = srch.save_data
      session[:list_type] = "conditions"
    end
    session[:filter] = nil if params[:clear] == "true"
    filter_set_defaults
    @filter = ""
    @cond = [""]

    session[:filter][:cond_columns] = Condition.cols if session[:filter][:cond_columns].nil?    
    session[:filter][:cond_hidden] = [] if session[:filter][:cond_hidden].nil?
    session[:filter][:cond_columns] = Condition.cols - session[:filter][:cond_hidden]
    
    if session[:filter][:avail_need]
      session[:filter][:cond_columns] << 'conditions.qty_needed' if !session[:filter][:cond_columns].include?('conditions.qty_needed') && !session[:filter][:cond_hidden].include?('conditions.qty_needed')
      session[:filter][:cond_columns] << 'conditions.surplus_individual' if !session[:filter][:cond_columns].include?('conditions.surplus_individual') && !session[:filter][:cond_hidden].include?('conditions.surplus_individual')
      if session[:filter][:avail_need]== 'Surplus' or session[:filter][:avail_need]== 'Both'         
        if session[:filter][:avail_need] != 'Both'
            @filter += (@filter.length > 0 ? ", " : "") + " Available "
            session[:filter][:cond_columns].delete('conditions.qty_needed')
        end
        cond_1 = "(conditions.type = 'Surplus')"              
      end    
      if session[:filter][:avail_need]== 'Need' or session[:filter][:avail_need]== 'Both'         
        if session[:filter][:avail_need] != 'Both'
          @filter += (@filter.length > 0 ? ", " : "") + " Needs "
          session[:filter][:cond_columns].delete('conditions.surplus_individual')
        end
        if session[:filter][:urgency_levels].nil? or session[:filter][:urgency_levels].keys == ["1","2","3","4"]
          cond_2 = "(conditions.type = 'Need')"
        else
          cond_2 = "(conditions.type = 'Need' and conditions.urgency in ('" + session[:filter][:urgency_levels].keys.join("','") + "'))"   
          @filter += (@filter.length > 0 ? ", " : "") +  "Level(s): '" + Need::Urgency.levels.values_at(*session[:filter][:urgency_levels].keys.collect{|k|k.to_i}).join(", ") + "'"          
        end                
      end      
      if session[:filter][:avail_need] == 'Both'      
        addcondition("(" + cond_1 + " OR " + cond_2 + ")")
      else  
        addcondition(cond_1) if cond_1
        addcondition(cond_2) if cond_2
      end
    end
    
    if session[:filter][:category] && session[:filter][:category] != 'All' && session[:filter][:item] == 'All'
      addcondition("categories_items.category_id = ?",session[:filter][:category])
      @selected_category = Category.find(session[:filter][:category])
      @filter += " Category='#{@selected_category.name}'"
      session[:list_type] = "category"
    end
    
    if session[:filter][:item] && session[:filter][:item] != 'All'
      addcondition("conditions.item_id = ?",session[:filter][:item])
      @selected_item = Item.find(session[:filter][:item])
      @filter += " Item='#{@selected_item.name}'"
      session[:list_type] = "item"
    end

#    if session[:filter][:fac_include] == 'Selected' ||  params[:state]
      session[:filter][:state] = params[:state] if params[:state]      
      conditions_for_facility
      if flash[:filter_error]
        flash[:notice] = flash[:filter_error]
        redirect_to :action => 'filter'
        return
      end
           
    params[:page] ||= 1 
    session[:filter][:linesperpage] = params[:linesperpage] if params[:linesperpage]        
    session[:filter][:linesperpage] ||= 20
    session[:filter][:linesperpage] = 500 if session[:filter][:linesperpage] == 'All' || session[:filter][:linesperpage].to_i > 500
    @offset = (params[:page].to_i - 1) * session[:filter][:linesperpage].to_i

    sql = " from conditions join shelters on shelters.id = conditions.shelter_id join items on items.id = conditions.item_id" +
          " left outer join users uc on uc.id = conditions.updatedbyid" + 
          (@cond[0].include?("(shelters_users.shelter_id = shelters.id)") ? " join shelters_users on shelters_users.shelter_id = shelters.id":"") 
    sql += " join categories_items on categories_items.item_id = conditions.item_id" if @cond[0].include?("categories_items")
    sql += ' where ' + @cond[0].gsub(/\(shelters_users.shelter_id = shelters.id\) AND/,"") if @cond[0].length > 0
    @cond.shift    
    sql1 = 'select count(*)' + sql
    @records = (Condition.find_by_sql ['select count(*)' + sql,*@cond])[0].count.to_i
    @pages = @records.divmod(session[:filter][:linesperpage].to_i)[0] + (@records.divmod(session[:filter][:linesperpage].to_i)[1] > 0 ? 1:0)
    order = session[:filter][:cond_sort].collect{|c|Condition.col_for_sort[Condition.cols.index(c.gsub(/\ DESC|\ ASC/,''))] + ' ' + c[c.rindex(' ') + 1,c.length]}.join(",") if session[:filter][:cond_sort] 
    order = "conditions.updated_at DESC" if order.blank?
    sql = "select is_this_user(shelters.id,#{session['user'].nil? ? '0':session['user']}),conditions.id, shelters.facility_type,conditions.shelter_id,conditions.item_id,conditions.type,uc.firstname as ucfn, uc.lastname as ucln,packaged_as," + Condition.cols.join(',') + sql
    sql = sql + ' order by ' + order
    sql = sql + " LIMIT " + session[:filter][:linesperpage].to_s + " OFFSET " + @offset.to_s    
    @conditions = Condition.find_by_sql [sql,*@cond]    
    render :action => 'newlist', :layout => 'reliefdb'        
  end

  def search
    session[:filter][:state] = params[:state] || "All"
    render :partial => "county", :layout => false
  end 
  
  def filter_category
    session[:filter][:category] = params[:category] || "All"
    render :partial => "items", :layout => false
  end
  
  def hide_col
    session[:filter][:cond_hidden] = [] if session[:filter][:cond_hidden].nil?
    session[:filter][:cond_hidden] << params[:hide]
    session[:filter][:cond_columns].delete(params[:hide])
    redirect_to :action => "list"
  end
  
  def show_col
    if params[:show] == "all" 
      session[:filter][:cond_hidden] = []
      session[:filter][:cond_columns] = Condition.cols     
    else
      session[:filter][:cond_columns] << params[:show]
      session[:filter][:cond_hidden].delete(params[:show])
    end
    redirect_to :action => "list"
  end
  
  def sort
    session[:filter][:cond_sort] = [] if session[:filter][:cond_sort].nil?
    if params[:sort] == "clear"
      session[:filter][:cond_sort] = nil
    else
      @found = false
      session[:filter][:cond_sort].collect! do |fld|
        if fld.starts_with?(params[:sort])
          @found = true
          params[:sort] + ' ' + params[:direction]
        else
          fld
        end       
      end   
      session[:filter][:cond_sort] << params[:sort] + ' ' + params[:direction] if not @found
    end       
    redirect_to :action => "list"
  end 
  
  def addcondition(newcond,newparam = nil)
    @cond = [""] if @cond.nil?
    @cond[0] += (@cond[0].length > 0 ? " AND ":"") + newcond
    @cond << newparam if newparam    
  end
#-----new code above this line/old code below this line-----------------------------------------------------

  def show
    begin
      @condition = Condition.where(:id => params[:id]).first
    rescue
      flash[:notice] = "I Am Sorry, But That Is Not A Valid ID"
      redirect_to :action => 'list'
      return
    end
    @title = "#{@condition.class}: " + @condition.name
    store_location
  end

  def new
    if params[:type] == "Need"
      @condition = Need.new
    elsif params[:type] == "Surplus"
      @condition = Surplus.new
    else
      # Error condition; how to handle? XXX
    end
    @title = "New " + params[:type]
    @condition.urgency = 3
    @condition.crate_preference = 0
    @condition.can_buy_local = 0
    @condition.shelter = Shelter.find_by_id(params[:shelter].to_i)
  end

  def create
    if params[:items]
      items = params[:items].keys.map {|i| Item.find_by_id(i.to_i)}
    else
      items = []
    end
    if params[:new_items]
      cat = Category.find_by_name("New/Unassigned")
      params[:new_items].split(/\n|\r/).each {|itemname|
	      itemname.strip!
        if itemname and itemname.size > 2
          if not item = Item.find(:first, :conditions => ["upper(name) = ?", itemname.upcase])
      	    item = Item.new
      	    item.name = itemname
      	    item.categories = [cat]
            item.set_updated_by User.find(session['user'])
      	    item.save
      	  end
    	  items << item
     	  end
        }
    end
    if params[:condition][:item_id]
      items << Item.find_by_id(params[:condition][:item_id].to_i)
    end
    success = true
    partial = false
    @shelter = Shelter.find_by_id(params[:shelter].to_i)
    for item in items
      if params[:type] == "Need"
        @condition = Need.new(params[:condition])
      elsif params[:type] == "Surplus"
        @condition = Surplus.new(params[:condition])
      else
        # Error condition; how to handle? XXX
      end
      @condition.shelter = @shelter
      @condition.item = item
      @condition.set_updated_by User.find(session['user'])
      if @condition.save
      	partial = true
      else
      	success = false
      end
    end
    @shelter.update_cond(User.find(session['user']))
    if success
      flash[:notice] = 'Condition was successfully created.'
      redirect_back_or_default :controller => 'shelters', :action => 'show', :id => params[:shelter]
    elsif partial
      flash[:notice] = 'Some conditions were created, but errors were encountered. Double-check results.'
      redirect_back_or_default :controller => 'shelters', :action => 'show', :id => params[:shelter]
    else
      render :action => 'new'
    end
  end

  def edit
    @condition = Condition.where(:id => params[:id]).first
    @title = "Edit #{@condition.class == Need ? "Need" : "Availability"}: " + @condition.name
  end

  def update
    @condition = Condition.where(:id => params[:id]).first
    @condition.set_updated_by User.find(session['user'])
    @condition.shelter.update_cond(User.find(session['user']))
    if @condition.update_attributes(params[:condition])
      flash[:notice] = 'Condition was successfully updated.'
      redirect_back_or_default :controller => 'shelters', :action => 'show', :id => @condition.shelter_id
    else
      render :action => 'edit', :retry => true
    end
  end

  def destroy
    condition = Condition.where(:id => params[:id]).first
    shelter = condition.shelter_id
    condition.destroy
    redirect_to :controller => 'shelters', :action => 'show', :id => shelter
  end

  def matches
    @avail = (params[:avail] == "1")
    @shelter = Shelter.find(params[:id])
    @cols = Array.new(self.class.cols) << 'Distance'
    @sortname = 'match_sort'
    setup_table_vars
    cond, sort = condsort_from_params
    if @avail
      @title = "Availability matches for #{@shelter.name}"
      @condition_ids, @distances, @loads = @shelter.avail_matches(cond, sort)
    else
      @title = "Need matches for #{@shelter.name}"
      @condition_ids, @distances, @loads = @shelter.need_matches(cond, sort)
    end
    @extra_columns << extra_column { |id|
      @distances[id] ? ((@distances[id].to_f * 0.6214 / 1000).round.to_s + " mi.") : "Unknown"
    }
    @extra_columns << extra_column(false) { |id|
      if loadid = @loads[id]
        l = Load.find(loadid)
        "<td style=\"background-color:#{l.bgcolor}\"><a HREF=\"#{url_for(:only_path => true, :controller => 'loads', :action => 'show', :id => loadid)}\">Load</A></td>" 
      elsif @avail
        "<td><A HREF=\"#{url_for(:only_path => true, :controller => 'loads', :action => 'new', :srcid => @shelter.id, :dstcond => id)}\">Ship</A></td>" 
      else
        "<td></td>"
      end
    }
    @extra_columns.each do |ec|
      puts ec.class
      puts ec.to_yaml
    end
    store_location
    @controller = self
    render :action => 'matches'
  end

end
