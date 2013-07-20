class Faq < ActiveRecord::Migration
  def self.up
    create_table :faq_entries do |t|
      t.column :created_at,     :datetime
      t.column :updated_at,     :datetime
      t.column :updated_by_id, :integer
      t.column :lock_version,   :integer,       :default => 0
      t.column :title,   :string
      t.column :text,  :text
      t.column :faq_category_id, :integer
      t.column :position, :integer
    end
    create_table :faq_categories do |t|
      t.column :created_at,     :datetime
      t.column :updated_at,     :datetime
      t.column :updated_by_id, :integer
      t.column :lock_version,   :integer,       :default => 0
      t.column :name,   :string
      t.column :position, :integer
    end

    execute "ALTER TABLE faq_entries ADD FOREIGN KEY (faq_category_id) REFERENCES faq_categories(id);"
    execute "ALTER TABLE faq_entries ALTER faq_category_id SET NOT NULL;"
  end

  def self.down
    drop_table :faq_entries
    drop_table :faq_categories
  end
end
