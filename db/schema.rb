# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131123020359) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: true do |t|
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "name"
  end

  create_table "categories_items", force: true do |t|
    t.integer "category_id"
    t.integer "item_id"
  end

  create_table "facilities", force: true do |t|
    t.text     "website"
    t.text     "phone"
    t.text     "address"
    t.boolean  "headquarters"
    t.text     "contact_name"
    t.string   "twitter"
    t.string   "facebook"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.text     "name"
    t.text     "state"
    t.text     "county"
    t.text     "city"
    t.boolean  "dc"
    t.integer  "dc_population"
    t.integer  "dc_shelters"
    t.integer  "dc_more"
    t.text     "mgt_phone"
    t.text     "supply_phone"
    t.text     "supply_contact_name"
    t.text     "notes"
    t.text     "zipcode"
    t.text     "other_notes"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "red_cross_status"
    t.text     "region"
    t.integer  "capacity"
    t.integer  "population"
    t.integer  "status"
    t.text     "org_name"
    t.text     "make_payable"
    t.integer  "facility_type"
    t.text     "hours"
    t.integer  "loading_docks"
    t.integer  "forklifts"
    t.integer  "workers"
    t.integer  "pallet_jacks"
    t.text     "client_contact_name"
    t.text     "client_contact_phone"
    t.text     "client_contact_address"
    t.text     "client_contact_email"
    t.integer  "waiting_list"
    t.text     "areas_served"
    t.text     "eligibility"
    t.text     "is_fee_required"
    t.decimal  "fee_amount",                precision: 7, scale: 2
    t.text     "payment_forms"
    t.text     "temp_perm"
    t.datetime "planned_enddate"
    t.text     "fee_is_for"
    t.text     "mission"
    t.text     "internal_notes"
    t.text     "clients_must_bring"
    t.text     "fee_explaination"
    t.text     "temp_perm_explaination"
    t.text     "waiting_list_explaination"
  end

  create_table "items", force: true do |t|
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "name"
    t.integer  "quantity"
  end

  create_table "items_resources", force: true do |t|
    t.integer "item_id"
    t.integer "resource_id"
  end

  create_table "loads", force: true do |t|
    t.text     "description"
    t.text     "stock"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "facility_id"
    t.text     "info_source"
    t.text     "notes"
    t.integer  "source_id"
    t.integer  "destination_id"
    t.text     "title"
    t.text     "trucker_name"
    t.text     "truck_reg"
    t.integer  "status"
    t.datetime "ready_by"
    t.datetime "etd"
    t.datetime "eta"
    t.integer  "transport_avail"
    t.integer  "routing_type"
  end

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.boolean  "approved",   default: false
  end

  create_table "organizations_users", force: true do |t|
    t.integer "organization_id"
    t.integer "user_id"
  end

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "resources", force: true do |t|
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "facility_id"
    t.integer  "load_id"
    t.text     "resource_type"
    t.text     "notes"
    t.integer  "qty_needed"
    t.integer  "surplus_individual"
    t.integer  "surplus_crates"
    t.integer  "qty_per_crate"
    t.boolean  "must_dispose_of_urgently"
    t.integer  "urgency"
    t.integer  "crate_preference"
    t.integer  "can_buy_local"
    t.text     "packaged_as"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "roles"
    t.boolean  "force_password_reset",   default: false
    t.text     "username"
    t.text     "first_name"
    t.text     "last_name"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
