class StatsNew < ActiveRecord::Migration
  def self.up
    add_column :histories, :was_new, :boolean

    execute "update histories set was_new = true where id in (select a.id from histories a, (select min(id) AS nid, objtype, objid from histories group by objtype, objid) b where a.id = b.nid);"
  end

  def self.down
    remove_column :histories, :was_new, :boolean
  end
end
