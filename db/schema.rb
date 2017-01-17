# -*- encoding : utf-8 -*-
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

ActiveRecord::Schema.define(version: 20170117145211) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "batch_uploads", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.text     "uploaded_resource_type"
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.string   "result_file_file_name"
    t.string   "result_file_content_type"
    t.integer  "result_file_file_size"
    t.datetime "result_file_updated_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["user_id"], name: "index_batch_uploads_on_user_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.text     "name",            null: false
    t.integer  "organization_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["organization_id", "name"], name: "index_categories_on_organization_id_and_name", unique: true, using: :btree
    t.index ["organization_id"], name: "index_categories_on_organization_id", using: :btree
  end

  create_table "checkins", force: :cascade do |t|
    t.integer  "user_id",                                                        null: false
    t.datetime "arrival_time",                                                   null: false
    t.datetime "exit_time"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.json     "data",                                              default: {}, null: false
    t.geometry "arrival_lonlat", limit: {:srid=>0, :type=>"point"}
    t.geometry "exit_lonlat",    limit: {:srid=>0, :type=>"point"}
    t.index ["arrival_lonlat"], name: "index_checkins_on_arrival_lonlat", using: :gist
    t.index ["exit_lonlat"], name: "index_checkins_on_exit_lonlat", using: :gist
    t.index ["user_id"], name: "index_checkins_on_user_id", using: :btree
  end

  create_table "communes", force: :cascade do |t|
    t.integer  "region_id"
    t.text     "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id", "name"], name: "index_communes_on_region_id_and_name", unique: true, using: :btree
    t.index ["region_id"], name: "index_communes_on_region_id", using: :btree
  end

  create_table "companies", force: :cascade do |t|
    t.text     "name"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["name", "organization_id"], name: "index_companies_on_name_and_organization_id", unique: true, using: :btree
    t.index ["organization_id"], name: "index_companies_on_organization_id", using: :btree
  end

  create_table "constructions", force: :cascade do |t|
    t.text     "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "company_id"
    t.index ["company_id"], name: "index_constructions_on_company_id", using: :btree
    t.index ["name", "company_id"], name: "index_constructions_on_name_and_company_id", unique: true, using: :btree
  end

  create_table "data_parts", force: :cascade do |t|
    t.text     "type",                           null: false
    t.text     "name",                           null: false
    t.text     "icon"
    t.boolean  "required",        default: true, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.json     "config",          default: {},   null: false
    t.integer  "position",        default: 0,    null: false
    t.integer  "detail_id"
    t.integer  "organization_id"
    t.integer  "section_id"
    t.integer  "data_part_id"
    t.index ["data_part_id"], name: "index_data_parts_on_data_part_id", using: :btree
    t.index ["detail_id"], name: "index_data_parts_on_detail_id", using: :btree
    t.index ["organization_id"], name: "index_data_parts_on_organization_id", using: :btree
    t.index ["section_id"], name: "index_data_parts_on_section_id", using: :btree
  end

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "device_token"
    t.text     "registration_id"
    t.text     "uuid"
    t.text     "architecture"
    t.text     "address"
    t.text     "locale"
    t.text     "manufacturer"
    t.text     "model"
    t.text     "name"
    t.text     "os_name"
    t.integer  "processor_count"
    t.text     "version"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "os_type"
    t.index ["user_id"], name: "index_devices_on_user_id", using: :btree
  end

  create_table "images", id: :uuid, default: nil, force: :cascade do |t|
    t.text     "url"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "category_id"
    t.uuid     "report_id"
    t.integer  "resource_id"
    t.text     "resource_type"
    t.text     "comment"
    t.index ["category_id"], name: "index_images_on_category_id", using: :btree
    t.index ["report_id"], name: "index_images_on_report_id", using: :btree
    t.index ["resource_id"], name: "index_images_on_resource_id", using: :btree
    t.index ["resource_type"], name: "index_images_on_resource_type", using: :btree
  end

  create_table "inspections", force: :cascade do |t|
    t.integer  "construction_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["construction_id"], name: "index_inspections_on_construction_id", using: :btree
  end

  create_table "invitations", force: :cascade do |t|
    t.integer  "role_id",                            null: false
    t.text     "confirmation_token",                 null: false
    t.text     "email",                              null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "accepted",           default: false, null: false
    t.text     "first_name"
    t.text     "last_name"
    t.text     "internal_id"
    t.index ["email"], name: "index_invitations_on_email", unique: true, using: :btree
    t.index ["internal_id"], name: "index_invitations_on_internal_id", unique: true, using: :btree
    t.index ["role_id"], name: "index_invitations_on_role_id", using: :btree
  end

  create_table "locations", force: :cascade do |t|
    t.geometry "lonlat",     limit: {:srid=>0, :type=>"point"}, null: false
    t.integer  "accuracy"
    t.bigint   "timestamp"
    t.text     "provider"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.text     "address"
    t.text     "region"
    t.text     "commune"
    t.text     "reference"
    t.index ["lonlat"], name: "index_locations_on_lonlat", using: :gist
  end

  create_table "menu_items", force: :cascade do |t|
    t.integer  "menu_section_id"
    t.text     "name",            null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "admin_path"
    t.index ["menu_section_id"], name: "index_menu_items_on_menu_section_id", using: :btree
  end

  create_table "menu_items_roles", id: false, force: :cascade do |t|
    t.integer "menu_item_id", null: false
    t.integer "role_id",      null: false
    t.index ["menu_item_id"], name: "index_menu_items_roles_on_menu_item_id", using: :btree
    t.index ["role_id"], name: "index_menu_items_roles_on_role_id", using: :btree
  end

  create_table "menu_sections", force: :cascade do |t|
    t.text     "name",            null: false
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "icon"
    t.text     "admin_path"
    t.index ["organization_id"], name: "index_menu_sections_on_organization_id", using: :btree
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree
  end

  create_table "organization_data", force: :cascade do |t|
    t.integer  "organization_id", null: false
    t.text     "path_suffix",     null: false
    t.text     "collection_name", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["organization_id", "collection_name"], name: "index_organization_data_on_organization_id_and_collection_name", unique: true, using: :btree
    t.index ["organization_id", "path_suffix"], name: "index_organization_data_on_organization_id_and_path_suffix", unique: true, using: :btree
    t.index ["organization_id"], name: "index_organization_data_on_organization_id", using: :btree
  end

  create_table "organizations", force: :cascade do |t|
    t.text     "name",                        null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "logo"
    t.text     "csv_separator", default: "|", null: false
    t.index ["name"], name: "index_organizations_on_name", unique: true, using: :btree
  end

  create_table "regions", force: :cascade do |t|
    t.text     "name",          null: false
    t.text     "roman_numeral", null: false
    t.integer  "number"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["name"], name: "index_regions_on_name", unique: true, using: :btree
    t.index ["roman_numeral"], name: "index_regions_on_roman_numeral", unique: true, using: :btree
  end

  create_table "report_columns", force: :cascade do |t|
    t.text     "field_name"
    t.text     "column_name"
    t.integer  "position"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "report_type_id",                null: false
    t.text     "relationship_name"
    t.integer  "data_type",         default: 1
    t.index ["report_type_id"], name: "index_report_columns_on_report_type_id", using: :btree
  end

  create_table "report_types", force: :cascade do |t|
    t.text     "name"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "title_field"
    t.text     "subtitle_field"
    t.index ["organization_id"], name: "index_report_types_on_organization_id", using: :btree
  end

  create_table "reports", id: :uuid, default: nil, force: :cascade do |t|
    t.integer  "report_type_id",                     null: false
    t.json     "dynamic_attributes", default: {},    null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "creator_id",                         null: false
    t.datetime "limit_date"
    t.boolean  "finished"
    t.integer  "assigned_user_id"
    t.text     "pdf"
    t.boolean  "pdf_uploaded",       default: false, null: false
    t.integer  "start_location_id"
    t.integer  "marked_location_id"
    t.integer  "finish_location_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "deleted_at"
    t.integer  "end_location_id"
    t.integer  "inspection_id"
    t.index ["assigned_user_id"], name: "index_reports_on_assigned_user_id", using: :btree
    t.index ["creator_id"], name: "index_reports_on_creator_id", using: :btree
    t.index ["deleted_at"], name: "index_reports_on_deleted_at", using: :btree
    t.index ["end_location_id"], name: "index_reports_on_end_location_id", using: :btree
    t.index ["finish_location_id"], name: "index_reports_on_finish_location_id", using: :btree
    t.index ["id"], name: "index_reports_on_id", using: :btree
    t.index ["inspection_id"], name: "index_reports_on_inspection_id", using: :btree
    t.index ["marked_location_id"], name: "index_reports_on_marked_location_id", using: :btree
    t.index ["report_type_id"], name: "index_reports_on_report_type_id", using: :btree
    t.index ["start_location_id"], name: "index_reports_on_start_location_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.integer  "organization_id", null: false
    t.text     "name",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["organization_id", "name"], name: "index_roles_on_organization_id_and_name", unique: true, using: :btree
    t.index ["organization_id"], name: "index_roles_on_organization_id", using: :btree
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.integer  "position"
    t.text     "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "report_type_id"
    t.integer  "section_type"
    t.index ["report_type_id"], name: "index_sections_on_report_type_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.text     "rut"
    t.text     "first_name"
    t.text     "last_name"
    t.text     "phone_number"
    t.text     "address"
    t.text     "image"
    t.integer  "role_id",                             null: false
    t.datetime "deleted_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["role_id"], name: "index_users_on_role_id", using: :btree
    t.index ["rut"], name: "index_users_on_rut", unique: true, using: :btree
  end

  add_foreign_key "batch_uploads", "users"
  add_foreign_key "categories", "organizations"
  add_foreign_key "checkins", "users"
  add_foreign_key "communes", "regions"
  add_foreign_key "companies", "organizations"
  add_foreign_key "constructions", "companies"
  add_foreign_key "data_parts", "data_parts"
  add_foreign_key "data_parts", "organizations"
  add_foreign_key "data_parts", "sections"
  add_foreign_key "devices", "users"
  add_foreign_key "images", "categories"
  add_foreign_key "images", "reports"
  add_foreign_key "inspections", "constructions"
  add_foreign_key "invitations", "roles"
  add_foreign_key "menu_items", "menu_sections"
  add_foreign_key "menu_sections", "organizations"
  add_foreign_key "organization_data", "organizations"
  add_foreign_key "report_columns", "report_types"
  add_foreign_key "report_types", "organizations"
  add_foreign_key "reports", "inspections"
  add_foreign_key "reports", "report_types"
  add_foreign_key "roles", "organizations"
  add_foreign_key "sections", "report_types"
  add_foreign_key "users", "roles"
end
