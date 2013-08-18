class Resource < ActiveRecord::Base
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updatedbyid"
  before_update :check_updated_by

  has_and_belongs_to_many :shelters

  def self.all_names
    [""] + self.all(:order => 'upper(kind), upper(name)').map {|r| r.kind + ": " + r.name}
  end
end
