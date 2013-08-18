class Project < ActiveRecord::Base
  set_primary_key :id 
  belongs_to :shelter
  after_update :save_tasks
  has_many :tasks, 
           :order => "position"
           
  def task_attributes=(task_attributes)  
    task_attributes.each_with_index do |attributes, idx|
      next if attributes[:id].blank? and attributes[:task_name].blank?
      if attributes[:id].blank?
        task = tasks.build(attributes)
      else      
        task = tasks.detect { |t| t.id == attributes[:id].to_i }
        task.attributes = attributes
      end      
    task.position = idx + 1
    end
  end
           
  def save_tasks
    tasks.each do |t|
      t.save
    end
  end
           
  def self.find_with_counts(type = :all)           
    find type,
      :select => "*,(select count(*) from tasks where tasks.project_id = projects.id) as tasks_cntr,(select count(*) from tasks where tasks.project_id = projects.id and tasks.done = true) as done_cntr"
  end
  
  def self.find_test
    find(:select => "*")
  end
           
  def percent_complete
    (done_cntr.to_f / tasks_cntr.to_f) * 100
  end  
  
end
