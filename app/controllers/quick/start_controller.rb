class Quick::StartController < ApplicationController

  layout 'general'

  def index    
    @page = read_page(startpage_path)    
    render :layout => 'reliefdb'
  end

  def edit
    @page = read_page(startpage_path)    
    render :layout => 'reliefdb'
  end

  def update
    if params[:commit] == 'Preview'
      @page = params[:quick_start_edit]
      render :action => 'edit', :layout => 'reliefdb'
    else
      write_page(File.expand_path("#{RAILS_ROOT}/app/views/quick/start/start.txt"),params[:quick_start_edit])
      redirect_to :action=> 'index'
    end
  end
  
  protected

  def startpage_path
    File.expand_path("#{RAILS_ROOT}/app/views/quick/start/start.txt")
  end

  def read_page(file)
    File.open(file) do |f|  
      begin
      chord = Marshal.load(f)  
    rescue
      chord = ""
    end
    end  
  end

  def write_page(file,page)
    File.open(file, "w+") do |f|
      Marshal.dump(page, f)
    end
  end
  
  
end
