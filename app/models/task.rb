class Task < ActiveRecord::Base
  #set_primary_key :id 
  belongs_to :project
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def status
    done ? 'Done': 'Pending'
  end
  
  def status=(newstatus)
    self.done = (newstatus == 'Done' ? true : false)
  end
  
end
