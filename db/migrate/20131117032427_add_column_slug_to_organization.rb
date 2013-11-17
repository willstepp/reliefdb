class AddColumnSlugToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :slug, :string
  end
end
