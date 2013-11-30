class AddForcePswdResetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :force_password_reset, :boolean, :default => false
  end
end
