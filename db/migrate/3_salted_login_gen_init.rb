class SaltedLoginGenInit < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :login,	:string
      t.column :salted_password,	:string
      t.column :email,	:string
      t.column :firstname,	:string
      t.column :lastname,	:string
      t.column :salt,	:string
      t.column :verified,	:integer,	:default => 0
      t.column :role,	:string
      t.column :security_token,	:string
      t.column :token_expiry,	:datetime
      t.column :created_at,	:datetime
      t.column :updated_at,	:datetime
      t.column :logged_in_at,	:datetime
      t.column :deleted,	:integer,	:default => 0
      t.column :delete_after,	:datetime
    end
  end

  def self.down
    drop_table :users
  end
end
