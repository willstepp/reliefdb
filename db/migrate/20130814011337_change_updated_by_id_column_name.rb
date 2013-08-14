class ChangeUpdatedByIdColumnName < ActiveRecord::Migration
  def self.up
    execute('ALTER TABLE shelters RENAME COLUMN updated_by_id to updatedbyid;')
    execute('ALTER TABLE categories RENAME COLUMN updated_by_id to updatedbyid;')
    execute('ALTER TABLE conditions RENAME COLUMN updated_by_id to updatedbyid;')
    execute('ALTER TABLE histories RENAME COLUMN updated_by_id to updatedbyid;')
    execute('ALTER TABLE items RENAME COLUMN updated_by_id to updatedbyid;')
    execute('ALTER TABLE loads RENAME COLUMN updated_by_id to updatedbyid;')
    execute('ALTER TABLE resources RENAME COLUMN updated_by_id to updatedbyid;')
  end

  def self.down
    execute('ALTER TABLE shelters RENAME COLUMN updatedbyid to updated_by_id;')
    execute('ALTER TABLE categories RENAME COLUMN updatedbyid to updated_by_id;')
    execute('ALTER TABLE conditions RENAME COLUMN updatedbyid to updated_by_id;')
    execute('ALTER TABLE histories RENAME COLUMN updatedbyid to updated_by_id;')
    execute('ALTER TABLE items RENAME COLUMN updatedbyid to updated_by_id;')
    execute('ALTER TABLE loads RENAME COLUMN updatedbyid to updated_by_id;')
    execute('ALTER TABLE resources RENAME COLUMN updatedbyid to updated_by_id;')
  end
end
