class HancockCounty < ActiveRecord::Migration
  def self.up
    add_column :shelters, :client_contact_name, :string
    add_column :shelters, :client_contact_address, :string
    add_column :shelters, :client_contact_phone, :string
    add_column :shelters, :client_contact_email, :string
    add_column :shelters, :waiting_list, :integer, :null => true
    add_column :shelters, :areas_served, :string
    add_column :shelters, :eligibility, :string
    add_column :shelters, :is_fee_required, :string, :size => 7
    add_column :shelters, :fee_amount, :float, :default => 0
    add_column :shelters, :payment_forms, :string
    add_column :shelters, :temp_perm, :string
    add_column :shelters, :planned_enddate, :date
  end

  def self.down
    remove_column :shelters, :client_contact_name
    remove_column :shelters, :client_contact_address
    remove_column :shelters, :client_contact_phone
    remove_column :shelters, :client_contact_email
    remove_column :shelters, :waiting_list
    remove_column :shelters, :areas_served
    remove_column :shelters, :eligibility
    remove_column :shelters, :is_fee_required
    remove_column :shelters, :fee_amount
    remove_column :shelters, :payment_forms
    remove_column :shelters, :temp_perm
    remove_column :shelters, :planned_enddate
    
  end
end
