class AddColumnsToFacility < ActiveRecord::Migration
  def change
    add_column :facilities, :name, :text, :limit => nil
    add_column :facilities, :state, :text, :limit => nil
    add_column :facilities, :county, :text, :limit => nil
    add_column :facilities, :city, :text, :limit => nil

    add_column :facilities, :dc, :boolean
    add_column :facilities, :dc_population, :integer
    add_column :facilities, :dc_shelters, :integer
    add_column :facilities, :dc_more, :integer

    add_column :facilities, :mgt_phone, :text, :limit => nil
    add_column :facilities, :supply_phone, :text, :limit => nil
    add_column :facilities, :supply_contact_name, :text, :limit => nil
    add_column :facilities, :notes, :text, :limit => nil
    add_column :facilities, :zipcode, :text, :limit => nil
    add_column :facilities, :other_notes, :text, :limit => nil

    add_column :facilities, :latitude, :float
    add_column :facilities, :longitude, :float

    add_column :facilities, :red_cross_status, :integer
    add_column :facilities, :region, :text, :limit => nil
    add_column :facilities, :capacity, :integer
    add_column :facilities, :population, :integer
    add_column :facilities, :status, :integer
    add_column :facilities, :org_name, :text, :limit => nil
    add_column :facilities, :make_payable, :text, :limit => nil
    add_column :facilities, :facility_type, :integer

    add_column :facilities, :hours, :text, :limit => nil
    add_column :facilities, :loading_docks, :integer
    add_column :facilities, :forklifts, :integer
    add_column :facilities, :workers, :integer
    add_column :facilities, :pallet_jacks, :integer
    add_column :facilities, :client_contact_name, :text, :limit => nil

    add_column :facilities, :client_contact_phone, :text, :limit => nil
    add_column :facilities, :client_contact_address, :text, :limit => nil
    add_column :facilities, :client_contact_email, :text, :limit => nil
    add_column :facilities, :waiting_list, :integer

    add_column :facilities, :areas_served, :text, :limit => nil
    add_column :facilities, :eligibility, :text, :limit => nil
    add_column :facilities, :is_fee_required, :text, :limit => nil
    add_column :facilities, :fee_amount, :decimal, :precision => 7, :scale => 2
    add_column :facilities, :payment_forms, :text, :limit => nil

    add_column :facilities, :temp_perm, :text, :limit => nil
    add_column :facilities, :planned_enddate, :datetime
    add_column :facilities, :fee_is_for, :text, :limit => nil
    add_column :facilities, :mission, :text, :limit => nil
    add_column :facilities, :internal_notes, :text, :limit => nil
    add_column :facilities, :clients_must_bring, :text, :limit => nil

    add_column :facilities, :fee_explaination, :text, :limit => nil
    add_column :facilities, :temp_perm_explaination, :text, :limit => nil
    add_column :facilities, :waiting_list_explaination, :text, :limit => nil
  end
end
