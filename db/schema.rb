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

ActiveRecord::Schema.define(version: 20170307021128) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.decimal  "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "claims", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "amount",             precision: 10, scale: 2
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "user_id"
    t.string   "aasm_state"
    t.string   "category"
    t.string   "vendor"
    t.string   "asset"
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
    t.index ["user_id"], name: "index_claims_on_user_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "price",       precision: 10, scale: 2
    t.integer  "quantity"
    t.string   "supplier"
    t.string   "link"
    t.string   "part_number"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "aasm_state"
    t.integer  "user_id"
    t.integer  "account_id"
    t.text     "comments"
    t.index ["account_id"], name: "index_orders_on_account_id", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "sales", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "amount",      precision: 10, scale: 2
    t.boolean  "printed"
    t.boolean  "paid"
    t.string   "payee"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "superadmin_role",        default: false
    t.boolean  "supervisor_role",        default: false
    t.boolean  "manager_role",           default: false
    t.boolean  "logistics_role",         default: false
    t.boolean  "approver_role",          default: false
    t.boolean  "user_role",              default: true
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string  "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.index ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
    t.index ["version_id"], name: "index_version_associations_on_version_id", using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.integer  "transaction_id"
    t.text     "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
    t.index ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree
  end

  create_table "wupee_notification_type_configurations", force: :cascade do |t|
    t.integer  "notification_type_id"
    t.string   "receiver_type"
    t.integer  "receiver_id"
    t.integer  "value",                default: 0
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["notification_type_id"], name: "idx_wupee_notif_type_config_on_notification_type_id", using: :btree
    t.index ["receiver_type", "receiver_id"], name: "idx_wupee_notif_typ_config_on_receiver_type_and_receiver_id", using: :btree
  end

  create_table "wupee_notification_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_wupee_notification_types_on_name", unique: true, using: :btree
  end

  create_table "wupee_notifications", force: :cascade do |t|
    t.string   "receiver_type"
    t.integer  "receiver_id"
    t.string   "attached_object_type"
    t.integer  "attached_object_id"
    t.integer  "notification_type_id"
    t.boolean  "is_read",              default: false
    t.boolean  "is_sent",              default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_foreign_key "claims", "users"
  add_foreign_key "orders", "users"
  add_foreign_key "wupee_notification_type_configurations", "wupee_notification_types", column: "notification_type_id"
  add_foreign_key "wupee_notifications", "wupee_notification_types", column: "notification_type_id"
end
