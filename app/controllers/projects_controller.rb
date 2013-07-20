class ProjectsController < ApplicationController
  layout "projects"
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
#  verify :method => :post, :only => [ :destroy, :create, :update ],
#         :redirect_to => { :action => :list }

  def list
    @user = session['user'].id
    @shelters = Shelter.project_shelters(session['user'], true)
    @project_pages, @projects = paginate :projects, :per_page => 10    
  end

  def show
    @project = Project.find_with_counts(params[:id])
  end

  def new
    @project = Project.new
    1.upto(5){|idx|@project.tasks.build}
  end
  
  def copy
    @proj = Project.find(params[:id])
    @project = Project.new(@proj.attributes)
    @proj.tasks.each do |tsk|
      @project.tasks.build(tsk.attributes)
    end
    render :action => 'new'
  end

  def create        
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = 'Project was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @project = Project.find_with_counts(params[:id])
  end

  def update    
    @project = Project.find(params[:id])
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to :action => 'show', :id => @project
    else
      render :action => 'edit'
    end
  end

  def destroy
    Project.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def update_positions    
    params[:sortable_list].each_index do |i|
      task = Task.find(params[:sortable_list][i])
      task.position = i
      task.save
#      @proj = task.project
    end
#    @tasks = @proj.tasks
#    render :partial => "tasks", :collection => @tasks
    render :nothing => true
  end
  
  def task_add
#    render :update do |page|
#      page.insert_html :before,"addtask", :partial => "task_edit", :object => Task.new     
#    end
     @project = Project.new(params)
     render :action => 'new'
  end
  
  def create_task
    render :update do |page|
      page.remove("task_add")
    end
  end
  
  def task_delete
    Task.destroy(params[:id])
    render :update do |page|
      page.remove("task_#{params[:id]}")
    end
  end
  
end
