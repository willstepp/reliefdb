class ZipAndOtherContacts < ActiveRecord::Migration
  def self.up
    add_column :shelters,	:zip,	:integer
    add_column :shelters,	:other_contacts,	:text
  end

  def self.down
    remove_column :shelters,	:zip
    remove_column :shelters,	:other_contacts
  end
end
