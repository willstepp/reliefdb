class SearchesController < ApplicationController
  include TableController
  layout 'reliefdb'
  
  def new 
    user = User.find(User.find(session['user']).id)
    @searches = user.searches.map{|s|    
      [s.save_name + s.updated_on.strftime(' (Last Updated %a, %m/%d/%Y %I:%M %p)'),s.id]
      }      
    session[:search_return] = params[:from] if params[:from]
  end
  
  def post  
     if params[:selected_action].nil?
       flash[:notice] = "You Must Choose 'Save New Search' or 'Replace Existing Search'"
       redirect_to :action => 'new'
       return
    end
    if params[:selected_action] == 'delete'
      if params[:update_id].nil?
        flash[:notice] = 'You Must Select A Search To Delete'
      else
        Search.delete(params[:update_id])
      end
      redirect_to :action => 'new'
      return
    end    
    user = User.find(User.find(session['user']).id)
    if params[:selected_action] == 'new'
      if params[:newname].nil? || params[:newname].empty? 
       flash[:notice] = "You Must Enter A Name For This Search"
       redirect_to :action => 'new'
       return          
      end
      srch = Search.new(:user_id => User.find(session['user']).id,:save_name => params[:newname],:save_data =>session[:filter])
      user.searches << srch
      if srch.save
      url = url_for(:controller => session[:search_return], :action=>'list',:preset => srch.id)
      flash[:notice] = "Search was successfully saved. The permalink for this search is <a href=#{url}> #{url}</a> <--Click This Link To Return To Your List"      
      else
        flash[:notice] = 'Save Failed'
        render :action => 'new'
      end
    end
    if params[:selected_action] == 'update'
      if params[:update_id].nil?
       flash[:notice] = "You Must Select The Search To Be Replaced"
       redirect_to :action => 'new'
       return        
      end
      search = user.searches.find(params[:update_id])
      search.save_data = session[:filter]
      search.save
      if search.save
        url = url_for(:controller => session[:search_return], :action=>'list',:preset => search.id)
        flash[:notice] = "Search was successfully saved. The permalink for this search is <a href=#{url}> #{url}</a> <--Click This Link To Return To Your List"
      else
        flash[:notice] = 'Save Failed'
        render :action => 'new'
      end
    end
    if params[:selected_action] == 'back'
      redirect_to :controller => session[:search_return], :action => 'list'
    else
      redirect_to :action => 'list'
    end
  end
  
  def list
    user = User.find(User.find(session['user']).id)
    @searches = user.searches    
  end
  
end

