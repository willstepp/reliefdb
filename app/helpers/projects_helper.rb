module ProjectsHelper
   def projects_select
     select(:project, :shelter_id,Shelter.project_shelters(User.find(session['user']),false).map{|s|[truncate(s.name,60,'...'),s.id]})
  end
end
