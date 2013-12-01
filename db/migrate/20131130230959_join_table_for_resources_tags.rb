class JoinTableForResourcesTags < ActiveRecord::Migration
  def change
  	  create_table :resources_tags do |t|
      t.belongs_to :resource
      t.belongs_to :tag
    end
  end
end
