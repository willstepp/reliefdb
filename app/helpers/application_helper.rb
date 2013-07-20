# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Localization
  include GmapHelper

  def info_source_explanation
    out = ''
    if @action_name != 'new'
      out += '<small>Note: If you are entering information from a new source, please replace old source information in this field with new source information; the old source information will still be kept in the history.</small><br />'
    end
    out + '<small><I>It is not necessary to enter your name or the date; those will be filled in automatically.</I></small><br />'
  end

  def display_history_for(o)
    out =  '<script type="text/javascript">
	      function toggleDisplay(elid) {
		el = document.getElementById(elid);
		if (el.style.display == "none") {
		  el.style.display = "inline";
		} else {
		  el.style.display = "none";
		}
	      }
	    </script>'
    out << '<b>Info Source/Changes: </b><br />'
    out << '<div id="shorthistory">'
    out << tf(o.access("info_source", session['user']))
    out << '<br />
	    <a href="javascript:void(0)" onclick="toggleDisplay(\'shorthistory\'); toggleDisplay(\'fullhistory\');"><small>(see full history)</small></a>
	    </div>
	    <div id="fullhistory" style="display:none">'
    for entry in o.history
      out << "<b>" + h(entry.timestamp) + " by " + h(entry.safe_upd_by) + ":</b><br />" + (entry.update_desc || "")
      out << '<a href="javascript:void(0)" onclick="toggleDisplay(\'changes' + entry.id.to_s + '\')"><small>(show/hide changes)</small></a><br />'
    end
    out << '<br /><a href="javascript:void(0)" onclick="toggleDisplay(\'shorthistory\'); toggleDisplay(\'fullhistory\');"><small>(hide history)</small></a><br />'
    out << '</div>'
    return out
  end

  def autoselect_for(table, field)
    vals = ActiveRecord::Base.connection.select_all("SELECT #{field} FROM #{table} GROUP BY #{field} ORDER BY #{field};").map {|r| r[field]}
    if vals[0] != ""
      vals.unshift("")
    end
    "<select id=\"select#{field}\" onchange=\"document.getElementById('#{table.singularize}_#{field}').value = this.value\">" + options_for_select(vals) + "</select>"
  end

  def autoselect_location
    out = javascript_tag "
      function set_shelter_location(str) {
	fields = str.split(' / ');
	document.getElementById('shelter_state').value = fields[0];
	document.getElementById('shelter_region').value = fields[1];
	document.getElementById('shelter_parish').value = fields[2];
	document.getElementById('shelter_town').value = fields[3];
      }
    "
    fields = 'state, region, parish, town'
    rows = ActiveRecord::Base.connection.select_all("SELECT #{fields} FROM shelters GROUP BY #{fields} ORDER BY #{fields};")
    vals = rows.map {|r| "#{r['state']} / #{r['region']} / #{r['parish']} / #{r['town']}" }
    out << "<select id=\"shelter_location\" onchange=\"set_shelter_location(this.value)\">"
    out << options_for_select(vals) + "</select>"
    return out
  end

  def select_boolean(obj, field)
    select obj, field, {'No' => false, 'Yes' => true}
  end

  def t_begin(tableid, ary)
    out = "<span style=\"display:none\" id=\"show_all_#{tableid}\">"
    out << render('shelters/showlinks')
    out << "</span>"
    out << "<table id=\"#{tableid}\">"
    return out + t_heads(tableid, ary)
  end

  def t_heads(tableid, ary)
    out = "<tr>"
    ary.each_index do |i|
      c = ary[i]
      id = c.downcase.gsub(' ', '_')
      if @sortclass.sorts[c]
        if @sorts.include?(c)
          lets = ((0..9).to_a + ('A'..'E').to_a).reverse
	  let = lets[(@sorts.size - @sorts.index(c) - 1)]
	  color = "#" + let.to_s*4 + "FF"
	  out << "<th id=\"th_#{id}\" style=\"background-color:#{color}\">"
        else
          out << "<th id=\"th_#{id}\">"
        end
        out << link_to(c, {:sort => c, :sort_req_id => (session['sort_req_id'] || 0) + 1}, {:style => "color:black;"})
      else
	out << "<th id=\"th_#{id}\">"
        out << c
      end
      out << "<br /><div style=\"font-size:80%;padding-top:5px\">"
      out << col_action_link("(hide)", tableid, :hide, i)
      out << "</div>"
      out << "</th>"
    end
    out << "</tr>"
    return out
  end

  def col_action_link(text, tableid, action, colid=nil)
    if action == :hide
      jfunc = "hide_table_column('#{tableid}', #{colid.to_i})"
      act = "hidecol"
    elsif action == :show
      jfunc = "show_table_column('#{tableid}', #{colid.to_i})"
      act = "showcol"
    elsif action == :showall
      jfunc = "show_all_columns('#{tableid}')"
      act = "showcol"
      colid = "all"
    else
      return
    end
    link_to_remote(text, :url => { :action => act, :id => colid, :state => params[:state], :region => params[:region], :parish => params[:parish] }, :update => { :success => "show_all_#{tableid}" }, :before => "#{jfunc}")
  end

  def cond_sort_form(cls)

    out = ""
    out << "State: "
    states = ActiveRecord::Base.connection.select_all("SELECT state FROM shelters WHERE state IS NOT NULL AND state != '' GROUP BY state ORDER BY state;").map {|h| h["state"] }
    states.unshift "All"
    out << "<select name=\"state\" id=\"state\" onchange=\"window.location = '#{url_for(:state => "")}' + this.value\">"
    out << options_for_select(states, params[:state])
    out << "</select>"

    out << " Region: "
    regions = ActiveRecord::Base.connection.select_all("SELECT state, region FROM shelters WHERE state IS NOT NULL AND state != '' AND region IS NOT NULL AND region != '' GROUP BY state, region ORDER BY state, region;").map {|h| "#{h['state']}/#{h['region']}" }
    regions.unshift "#{params[:state] || 'All'}/All"
    out << "<select name=\"region\" id=\"region\" onchange=\"window.location = '#{url_for(:state => "")}' + this.value\">"
    out << options_for_select(regions, "#{params[:state]}/#{params[:region]}")
    out << "</select>"

    if params[:state] and params[:state] != 'All'
      out << " County: "
      counties = ActiveRecord::Base.connection.select_all("SELECT parish FROM shelters WHERE state = '#{sqlsafe params[:state]}' GROUP BY parish ORDER BY parish;").map {|h| h['parish']}
      counties.unshift "All"
      out << "<select name=\"parish\" id=\"parish\" onchange=\"window.location = '#{url_for(:state => params[:state], :parish => "")}' + this.value\">"
      out << options_for_select(counties, params[:parish])
      out << "</select>"
    end

    out << " Facility Type: "
    types = Shelter::FacilityType.levels.values.sort
    types.unshift "All"
    types.unshift "All, Except Businesses"
    out << "<select name=\"factype\" id=\"factype\" onchange=\"window.location = '#{url_for(:factype => "")}' + this.value\">"
    out << options_for_select(types, params[:factype])
    out << "</select>"

    out << "<br />"
    out << "  "
    out << check_box_tag("show_closed", "1", params[:show_closed] != "0", :onclick => "window.location = '#{url_for(:show_closed => (params[:show_closed].to_i + 1) % 2)}'")
    out << " Include closed facilities | "
    out << check_box_tag("show_regional", "1", params[:show_regional] != "0", :onclick => "window.location = '#{url_for(:show_regional => (params[:show_regional].to_i + 1) % 2)}'")
    out << " Include regional facilities "
    if session['user']
      out << " | "
      out << "<span style=\"background-color:red\">" if params[:show_only_my] != "0"
      out << check_box_tag("show_only_my", "1", params[:show_only_my] != "0", :onclick => "window.location = '#{url_for(:show_only_my => (params[:show_only_my].to_i + 1) % 2)}'")
      out << " Show only My Facilities "
      out << "</span>" if params[:show_only_my] != "0"
    end

    if cls == "Condition"
      out << "<br />"
      out << check_box_tag("show_urgent", "1", params[:show_urgent] != "0", :onclick => "window.location = '#{url_for(:show_urgent => (params[:show_urgent].to_i + 1) % 2)}'")
      out << " Include Urgent/Very Urgent Only"
      out << check_box_tag("show_servaff", "1", params[:show_servaff] != "0", :onclick => "window.location = '#{url_for(:show_servaff => (params[:show_servaff].to_i + 1) % 2)}'")                
      out << " Include Services and Affiliations"      
    end
     
    out << "<p>"
    out << "Legend: "
    Shelter::FacilityType.levels.invert.sort.each do |a|
      f = Shelter::FacilityType.new(a[1])
      out << link_to(f.bgcolored, :factype => f.to_s)
      out << " "
    end
    out << "<br />"
    if ["Open Business*", "All"].include?(params[:factype])
      out << "<div style=\"margin:0;font-size:smaller;background-color:#{Shelter::FacilityType.new(11).bgcolor}\">* Note: The 'Open Business' listings contain for-profit organizations. Items offered by these organization are generally not available for free. Such facilities are listed as a convenience, in areas where many businesses are closed. The listing of such businesses does not imply any endorsement by CAT. CAT does not receive any consideration for these listings.</div>"
    end
    out << "<br />"

    out << "Sorting by: "
    out << @sorts.map {|s| link_to(s, :basesort => s, :sort_req_id => (session['sort_req_id'] || 0 ) + 1)}.join(" / ")
    out << " <small>(" + link_to("help!", "javascript:alert('If you have trouble getting the hang of the new sort system, remember this simple rule: If you click a column heading twice in a row, everything will be reset and you\\\'ll be sorting only by that column. If you can\\\'t figure out what\\\'s going on, just click the column you want to sort by, and if it doesn\\\'t work, click it again.')") +")</small>"
    if @controller.all_stored.map {|v| session[v]}.compact.size > 0
      out << " | "
      out << link_to("<B style=\"color:red\">Clear All Sort/Filter Settings</B>", :clear_all => true, :state => nil)
    end
    return out
  end

  def back_to(default)
    if session['return-to'] != request.request_uri
      link_to("Back", session['return-to'])
    else
      link_to("Back", default)
    end
  end

  def date_text_field(model, field)
    begin
      d = instance_variable_get("@" + model.to_s).send(field)
      val = d.strftime("%m/%d/%y %I:%M%p").downcase
    rescue
      val = ""
    end
    return "<input id=\"#{model}_#{field}\" name=\"#{model}[#{field}]\" size=\"30\" type=\"text\" value=\"#{val}\" />"
  end
#-----new code below this line---------------------------------------
  def no_empty_cell(contents)
    contents.nil? || contents.to_s.empty? ? "&nbsp" : h(contents) 
  end
  
  def state_select(onchange = true)
    st = Shelter.find(:all, :select => "state",
                            :conditions => "state <> ''", 
                            :group => "state", 
                            :order => "state").map {|f| [f.state,f.state]}
    st.unshift("All").delete("")
    select_tag("state",options_for_select(st, session[:filter][:state]),:onchange => (onchange ? "parent.location='/#{params[:controller]}/list?state=' + encodeURIComponent(value)" : nil)   )
  end
   
  def text_with_label(label, field, options = {})   
    options = {:clean => true}.merge(options)
    clean = options.delete(:clean)
    style = options.delete(:labelstyle)
    return if field.blank?
    out = "<b style = '#{style}'>#{label}</b>"
    out << (clean ? h(field) : field)
    out << '<br />'
  end
#-----new code above this line---------------------------------------
end
