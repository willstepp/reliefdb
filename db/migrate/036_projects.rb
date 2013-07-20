class Projects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
      t.column :lock_version, :integer, :default => 0
      t.column :shelter_id, :integer
      t.column :project_name, :string
      t.column :project_notes, :text
    end    

    create_table :tasks do |t|
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
      t.column :lock_version, :integer, :default => 0
      t.column :project_id, :integer
      t.column :task_name, :string
      t.column :done, :boolean, :default => false
      t.column :position, :integer, :default => 0
    end    
    execute  "CREATE OR REPLACE FUNCTION task_count(project_id int4)
      RETURNS _int8 AS
      $BODY$select array[count(*),
        sum(case when done = true then 1 else 0 end)]
        from tasks where project_id = $1
      $BODY$
      LANGUAGE 'sql' VOLATILE;"   
    
  end

  def self.down
    drop_table :projects
    drop_table :tasks
    execute  "DROP FUNCTION task_count(project_id int4);"
  end
end
