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

ActiveRecord::Schema.define(version: 20140428120523) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channels", force: true do |t|
    t.string   "name",         default: "",                    null: false
    t.string   "source",       default: "",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "channel_type"
    t.datetime "last_pull_at", default: '2014-04-29 08:26:48'
  end

  add_index "channels", ["source"], name: "index_channels_on_source", unique: true, using: :btree

  create_table "channels_master_rakes", force: true do |t|
    t.integer "master_rake_id"
    t.integer "channel_id"
    t.boolean "display",        default: true
  end

  add_index "channels_master_rakes", ["channel_id", "master_rake_id"], name: "index_channel_master_rake_on_master_rake_id_and_channel_id", unique: true, using: :btree

  create_table "filters", force: true do |t|
    t.string   "keyword"
    t.integer  "filter_type"
    t.integer  "rake_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "heap_leaflet_maps", force: true do |t|
    t.integer  "heap_id"
    t.integer  "leaflet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "heap_leaflet_maps", ["heap_id", "leaflet_id"], name: "index_heap_leaflet_maps_on_heap_id_and_leaflet_id", unique: true, using: :btree

  create_table "heaps", force: true do |t|
    t.integer  "rake_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leaflets", force: true do |t|
    t.integer  "channel_id"
    t.text     "content",      default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
    t.text     "identifier"
    t.text     "title"
    t.text     "url"
    t.text     "author"
    t.text     "image"
    t.integer  "save_count",   default: 0
    t.integer  "view_count",   default: 0
  end

  add_index "leaflets", ["identifier"], name: "index_leaflets_on_identifiers", unique: true, using: :btree

  create_table "master_rakes", force: true do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "master_rakes", ["name"], name: "index_master_rakes_on_name", unique: true, using: :btree

  create_table "rake_channel_maps", force: true do |t|
    t.integer  "channel_id"
    t.integer  "rake_id"
    t.string   "options",    default: "",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "display",    default: true
  end

  add_index "rake_channel_maps", ["channel_id"], name: "index_rake_channel_maps_on_channel_id", using: :btree
  add_index "rake_channel_maps", ["rake_id", "channel_id"], name: "index_rake_channel_maps_on_rake_id_and_channel_id", unique: true, using: :btree
  add_index "rake_channel_maps", ["rake_id"], name: "index_rake_channel_maps_on_rake_id", using: :btree

  create_table "rakes", force: true do |t|
    t.string   "name",               default: "", null: false
    t.integer  "master_rake_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.datetime "refreshed_at"
    t.integer  "snapshot_count",     default: 0
    t.datetime "saved_refreshed_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
