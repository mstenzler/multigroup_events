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

ActiveRecord::Schema.define(version: 20141022000951) do

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "token_secret"
    t.string   "refresh_token"
    t.datetime "expires_at"
    t.boolean  "expires",       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geo_areas", force: true do |t|
    t.integer  "geo_country_id"
    t.string   "place_name",     limit: 200
    t.string   "state",          limit: 100
    t.string   "state_code",     limit: 20
    t.string   "zip",            limit: 10
    t.float    "latitude"
    t.float    "longitude"
    t.string   "source",         limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_areas", ["geo_country_id", "state"], name: "geo_area_state_opt", using: :btree
  add_index "geo_areas", ["geo_country_id", "state_code"], name: "geo_area_state_code_opt", using: :btree
  add_index "geo_areas", ["geo_country_id", "zip"], name: "geo_area_zip_opt", using: :btree

  create_table "geo_cities", force: true do |t|
    t.string   "city_name",       limit: 80
    t.string   "short_city_name", limit: 60
    t.integer  "geo_region_id"
    t.integer  "geo_country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_cities", ["geo_country_id", "geo_region_id"], name: "geo_cities_region_opt", using: :btree

  create_table "geo_continents", force: true do |t|
    t.string   "continent_name", limit: 25
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geo_countries", force: true do |t|
    t.string   "country_code",       limit: 2
    t.string   "country_name",       limit: 100
    t.boolean  "has_geo_data"
    t.string   "short_country_name", limit: 40
    t.integer  "geo_continent_id"
    t.integer  "dial_code"
    t.boolean  "has_geo_regions"
    t.integer  "rank"
    t.integer  "rank_level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_countries", ["country_code"], name: "country_code_opt", unique: true, using: :btree

  create_table "geo_regions", force: true do |t|
    t.string   "region_name",       limit: 35
    t.string   "short_region_name", limit: 25
    t.integer  "geo_country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_regions", ["geo_country_id"], name: "regions_country_code_opt", using: :btree

  create_table "locations", force: true do |t|
    t.integer  "user_id"
    t.string   "name",                 limit: 70
    t.string   "address"
    t.string   "formatted_address"
    t.integer  "geo_area_id"
    t.string   "privacy",              limit: 24
    t.integer  "category_id"
    t.boolean  "is_private_residence"
    t.string   "state",                limit: 24
    t.string   "editable_by",          limit: 24
    t.integer  "owner_user_id"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.integer  "user_id"
    t.integer  "default_profile_view_id"
    t.string   "short_description"
    t.text     "long_description"
    t.boolean  "enable_personal",         default: false
    t.boolean  "enable_business",         default: false
    t.boolean  "enable_resume",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], name: "profile_user_id_opt", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                     limit: 32
    t.string   "email",                    limit: 50
    t.string   "username",                 limit: 24
    t.string   "gender",                   limit: 20
    t.date     "birthdate"
    t.string   "avatar"
    t.string   "avatar_type"
    t.string   "time_zone"
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "auth_token"
    t.string   "validation_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "email_validation_token"
    t.string   "ip_address_created"
    t.string   "ip_address_last_modified"
    t.string   "ip_address_last_login"
    t.boolean  "email_validated",                     default: false
    t.datetime "email_validated_at"
    t.datetime "email_changed_at"
    t.boolean  "admin",                               default: false
    t.datetime "last_login_at"
    t.boolean  "is_verified"
    t.boolean  "birthdate_is_verified"
    t.datetime "date_verified"
    t.integer  "verified_by_id"
    t.integer  "age"
    t.datetime "age_last_checked"
    t.string   "age_display_type",         limit: 32
    t.integer  "geo_country_id"
    t.integer  "geo_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
