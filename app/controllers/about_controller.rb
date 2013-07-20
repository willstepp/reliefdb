class AboutController < ApplicationController

  layout "general"
  model "user"

  def index
  end

  def contact
    if params[:id]
      user = User.find(params[:id])
      user.verified = params[:verified] if params[:verified]
      user.priv_read = params[:priv_read] if params[:priv_read]      
      user.priv_new_shelters = params[:priv_new_shelters] if params[:priv_new_shelters]
      user.priv_read_sensitive = params[:priv_read_sensitive] if params[:priv_read_sensitive]
      user.priv_write = params[:priv_write] if params[:priv_write]      
      user.priv_admin = params[:priv_admin] if params[:priv_admin]
      user.save
    end
  end

  def help
    case params[:id]
      when "facility"      
        render :file => 'about/helpfaclist', :use_full_path => true
      when "search"
        @helpreturn = params[:helpreturn]
        render :file => 'about/helpsearch', :use_full_path => true
      when "conditions"
        render :file => 'about/helpcondlist', :use_full_path => true
      else
        render :action => 'help'
    end    
  end

  def faq
  end

end
