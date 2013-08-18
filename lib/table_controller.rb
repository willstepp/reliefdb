module TableController

  def all_stored
    [
        'shelter_list_state',
        'shelter_list_region',
        'shelter_list_parish',
        'factype',
        'show_closed',
        'show_regional',
        'show_only_my',
        'show_urgent',
        @sortname,
        @hidecolname,
    ]
  end

  def setup_table_vars_only
    @title ||= ""
    @tableid ||= self.class.tableid
    @cols ||= self.class.cols
    @sortclass ||= self.class.sortclass
    @sortname ||= @sortclass.to_s.downcase + "_sort"
    @hidecolname ||= self.class.hidecolname
    @default_hidecols ||= self.class.default_hidecols
    @extra_columns ||= []
  end

  def setup_table_vars
    setup_table_vars_only

    if params[:clear_all]
      all_stored.each {|k| session[k] = nil}
    end

    if session[@hidecolname]
      @hidecols = Set.new(session[@hidecolname])
    else
      @hidecols = Set.new(@default_hidecols)
    end
    if params[:state] and params[:state] != "All"
      @hidecols << 1
    end
    if (params[:parish] and params[:parish] != "All") or (params[:region] and params[:region] != "All")
      @hidecols << 2
    end
    if params[:parish] and params[:parish] != "All"
      @hidecols << 3
    end
  end

  def showcol
    setup_table_vars_only
    if params[:id] == 'all'
      session[@hidecolname] = Set.new
    else
      session[@hidecolname] ||= Set.new(@default_hidecols)
      session[@hidecolname].delete(params[:id].to_i)
    end
    setup_table_vars
    render_without_layout 'shelters/showlinks'
  end

  def hidecol
    setup_table_vars_only
    session[@hidecolname] ||= Set.new(@default_hidecols)
    session[@hidecolname] << params[:id].to_i
    setup_table_vars
    render_without_layout 'shelters/showlinks'
  end

  def condsort_from_params(source=nil)

    if params[:show_regional]
      session['show_regional'] = params[:show_regional]
    else
      params[:show_regional] = session['show_regional']
    end
    if params[:show_regional].nil?
      params[:show_regional] = "1"
    end

    if not params[:state] and session['shelter_list_state']
      params[:state] = session['shelter_list_state']
      if session['shelter_list_region']
        params[:region] = session['shelter_list_region']
      end
      if session['shelter_list_parish']
        params[:parish] = session['shelter_list_parish']
      end
    else
      session['shelter_list_state'] = params[:state]
      session['shelter_list_region'] = params[:region]
      session['shelter_list_parish'] = params[:parish]
    end
    if params[:state] and params[:state] != "All"
      if params[:region] and params[:region] != "All"
        if params[:show_regional].to_i == 1
          cond = ["(shelters.state = ? OR shelters.state = '') AND (shelters.region = ? OR shelters.region = '')", params[:state], params[:region]]
        else
          cond = ["(shelters.state = ?) AND (shelters.region = ?)", params[:state], params[:region]]
        end
        @title = params[:state] + "/" + params[:region] + " " + @title
      elsif params[:parish] and params[:parish] != "All"
        if params[:show_regional].to_i == 1
          cond = ["(shelters.state = ? OR shelters.state = '') AND (shelters.parish = ? OR shelters.parish = '')", params[:state], params[:parish]]
        else
          cond = ["(shelters.state = ?) AND (shelters.parish = ?)", params[:state], params[:parish]]
        end
        @title = params[:state] + "/" + params[:parish] + " " + @title
      else
        if params[:show_regional].to_i == 1
          cond = ["(shelters.state = ? OR shelters.state = '')", params[:state]]
        else
          cond = ["(shelters.state = ?)", params[:state]]
        end
        @title = params[:state] + " " + @title
      end
    else
      if params[:show_regional].to_i == 1
        cond = nil
      else
        cond = ["shelters.state != ''"]
      end
    end

    if params[:factype]
      session['factype'] = params[:factype]
    else
      params[:factype] = session['factype']
    end
    if params[:factype].nil?
      params[:factype] = "All, Except Businesses"
    end
    if params[:factype] == "All, Except Businesses"
      if cond
	cond[0] += " AND (shelters.facility_type != 11)"
      else
        cond = ["(shelters.facility_type != 11)"]
      end
    elsif params[:factype] != "All"
      i = Shelter::FacilityType.levels.invert[params[:factype]]
      if i
        if cond
          cond[0] += " AND (shelters.facility_type = #{i})"
        else
          cond = ["(shelters.facility_type = #{i})"]
        end
      end
    end

    if params[:show_urgent]
      session['show_urgent'] = params[:show_urgent]
    else
      params[:show_urgent] = session['show_urgent']
    end
    if params[:show_urgent].nil?
      params[:show_urgent] = "0"
    end
    if params[:show_urgent] == "1" and source == "Condition"
      if cond
        cond[0] += " AND (conditions.urgency <= 2)"
      else
        cond = ["(conditions.urgency <= 2)"]
      end
    end
    
    if params[:show_servaff]
      session['show_servaff'] = params[:show_servaff]
    else
      params[:show_servaff] = session['show_servaff']
    end
    if params[:show_servaff].nil?
      params[:show_servaff] = "1"
    end
 
    if params[:show_closed]
      session['show_closed'] = params[:show_closed]
    else
      params[:show_closed] = session['show_closed']
    end
    if params[:show_closed].nil?
      params[:show_closed] = "1"
    end
    if params[:show_closed] == "0"
      if cond
        cond[0] += " AND (shelters.status != 3 OR shelters.status IS NULL)"
      else
        cond = ["(shelters.status != 3 OR shelters.status IS NULL)"]
      end
    end

    if params[:show_only_my]
      session['show_only_my'] = params[:show_only_my]
    else
      params[:show_only_my] = session['show_only_my']
    end
    if params[:show_only_my].nil?
      params[:show_only_my] = "0"
    end
    if params[:show_only_my] == "1" && User.find(session['user'])
      if cond
        cond[0] += " AND (shelters_users.shelter_id = shelters.id) AND (shelters_users.user_id = #{User.find(session['user']).id})"
      else
        cond = ["(shelters_users.shelter_id = shelters.id) AND (shelters_users.user_id = #{User.find(session['user']).id})"]
      end
    end

    defaults = parse_sorts(default_sort_name)
    sorts = Array.new(session[@sortname] || defaults)
    session['sort_req_id'] ||= 0
    if params[:sort_req_id] && params[:sort_req_id].to_i > session['sort_req_id']
      session['sort_req_id'] = params[:sort_req_id].to_i
      if newsort = params[:sort] and @sortclass.sorts[newsort]
        if !session[@sortname]
          sorts = []
        elsif sorts.include?(newsort)
          if sorts.index(newsort) + 1 == sorts.size
    	    sorts = []
          else
            sorts.delete(newsort)
          end
        end
        append_sort(sorts, newsort)
      elsif newbase = params[:basesort] and @sortclass.sorts[newbase]
        if i = sorts.index(newbase)
  	  sorts = sorts[i, sorts.size]
        else
	  sorts = []
	  append_sort(sorts, newbase)
        end
      end
      session[@sortname] = Array.new(sorts)
    end
    
    @sorts = Array.new(sorts)
    lastsort = @sortclass.last_sort
    sorts << lastsort if not sorts.include?(lastsort)
    @sorts_and_last = Array.new(sorts)
    sort = sorts.map {|s| @sortclass.sorts[s]}.compact.join(", ")

    #sorts.each { |s| @hidecols.delete(@cols.index(s)) } if @hidecols

    return cond, sort
  end

  def append_sort(sorts, sort)
    if ['Region', 'County', 'Town'].include?(sort) and not sorts.include?('State')
      sorts << 'State'
    end
    sorts << sort
  end

  def default_sort_name
    @sortclass.send('default_sort_name')
  end

  def parse_sorts(str)
    str.split('/').map { |s| @sortclass.sorts[s] && s }.compact
  end
    
  def totals
    setup_table_vars_only
    cond, sort = condsort_from_params
    @totals = {}
    @stotals = {}
    @tottot = @sortclass.send('count', cond)
    Shelter::FacilityType.levels.invert.sort.each do |a|
      t = a[1]
      all = 0
      @totals[t] = {}
      for s in Shelter::Status.levels.keys
        if s != 3 or params[:show_closed] != "0"
          if cond
            c = Array.new(cond)
            c[0] += " AND "
          else
            c = [""]
          end
          c[0] += "shelters.facility_type = #{t} AND shelters.status = #{s}"
          count = @sortclass.send('count', c)
          @totals[t][s] = count
          all += count
          @stotals[s] = (@stotals[s] || 0 ) + count
        end
      end
      @totals[t][:all] = all
    end
    render :layout => 'iframe'
  end

  def extra_column(tds = true)
    proc {|id|
      out = tds ? "<td>" : ""
      val = yield id
      if val and val.to_s != ""
        out << val.to_s
      end
      out << "</td>" if tds
      out
    }
  end

end
