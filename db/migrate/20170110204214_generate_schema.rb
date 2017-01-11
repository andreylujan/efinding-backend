class GenerateSchema < ActiveRecord::Migration[5.0]
  def change

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
    end

    add_index "batch_uploads", ["user_id"], name: "index_batch_uploads_on_user_id", using: :btree

    create_table "categories", force: :cascade do |t|
      t.text     "name",            null: false
      t.integer  "organization_id", null: false
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
    end

    add_index "categories", ["organization_id", "name"], name: "index_categories_on_organization_id_and_name", unique: true, using: :btree
    add_index "categories", ["organization_id"], name: "index_categories_on_organization_id", using: :btree

    create_table "checkins", force: :cascade do |t|
      t.integer  "user_id",                                                        null: false
      t.datetime "arrival_time",                                                   null: false
      t.datetime "exit_time"
      t.datetime "created_at",                                                     null: false
      t.datetime "updated_at",                                                     null: false
      t.json     "data",                                              default: {}, null: false
      t.geometry "arrival_lonlat", limit: {:srid=>0, :type=>"point"}
      t.geometry "exit_lonlat",    limit: {:srid=>0, :type=>"point"}
    end

    add_index "checkins", ["arrival_lonlat"], name: "index_checkins_on_arrival_lonlat", using: :gist
    add_index "checkins", ["exit_lonlat"], name: "index_checkins_on_exit_lonlat", using: :gist
    add_index "checkins", ["user_id"], name: "index_checkins_on_user_id", using: :btree

    create_table "communes", force: :cascade do |t|
      t.integer  "region_id"
      t.text     "name",       null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "communes", ["region_id", "name"], name: "index_communes_on_region_id_and_name", unique: true, using: :btree
    add_index "communes", ["region_id"], name: "index_communes_on_region_id", using: :btree

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
    end

    add_index "data_parts", ["data_part_id"], name: "index_data_parts_on_data_part_id", using: :btree
    add_index "data_parts", ["detail_id"], name: "index_data_parts_on_detail_id", using: :btree
    add_index "data_parts", ["organization_id"], name: "index_data_parts_on_organization_id", using: :btree
    add_index "data_parts", ["section_id"], name: "index_data_parts_on_section_id", using: :btree

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
    end

    add_index "devices", ["user_id"], name: "index_devices_on_user_id", using: :btree

    create_table "images", force: :cascade do |t|
      t.text     "url"
      t.datetime "created_at",    null: false
      t.datetime "updated_at",    null: false
      t.integer  "category_id"
      t.uuid     "report_id"
      t.integer  "resource_id"
      t.text     "resource_type"
      t.text     "comment"
      t.text     "uuid"
    end

    add_index "images", ["category_id"], name: "index_images_on_category_id", using: :btree
    add_index "images", ["report_id"], name: "index_images_on_report_id", using: :btree
    add_index "images", ["resource_id"], name: "index_images_on_resource_id", using: :btree
    add_index "images", ["resource_type"], name: "index_images_on_resource_type", using: :btree
    add_index "images", ["uuid"], name: "index_images_on_uuid", unique: true, using: :btree

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
    end

    add_index "invitations", ["email"], name: "index_invitations_on_email", unique: true, using: :btree
    add_index "invitations", ["internal_id"], name: "index_invitations_on_internal_id", unique: true, using: :btree
    add_index "invitations", ["role_id"], name: "index_invitations_on_role_id", using: :btree

    create_table "locations", force: :cascade do |t|
      t.geometry "lonlat",     limit: {:srid=>0, :type=>"point"}, null: false
      t.integer  "accuracy"
      t.integer  "timestamp",  limit: 8
      t.text     "provider"
      t.datetime "created_at",                                    null: false
      t.datetime "updated_at",                                    null: false
      t.text     "address"
      t.text     "region"
      t.text     "commune"
      t.text     "reference"
    end

    add_index "locations", ["lonlat"], name: "index_locations_on_lonlat", using: :gist

    create_table "menu_items", force: :cascade do |t|
      t.integer  "menu_section_id"
      t.text     "name",            null: false
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
      t.text     "admin_path"
    end

    add_index "menu_items", ["menu_section_id"], name: "index_menu_items_on_menu_section_id", using: :btree

    create_table "menu_items_roles", id: false, force: :cascade do |t|
      t.integer "menu_item_id", null: false
      t.integer "role_id",      null: false
    end

    add_index "menu_items_roles", ["menu_item_id"], name: "index_menu_items_roles_on_menu_item_id", using: :btree
    add_index "menu_items_roles", ["role_id"], name: "index_menu_items_roles_on_role_id", using: :btree

    create_table "menu_sections", force: :cascade do |t|
      t.text     "name",            null: false
      t.integer  "organization_id"
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
      t.text     "icon"
      t.text     "admin_path"
    end

    add_index "menu_sections", ["organization_id"], name: "index_menu_sections_on_organization_id", using: :btree

    create_table "oauth_access_grants", force: :cascade do |t|
      t.integer  "resource_owner_id", null: false
      t.integer  "application_id",    null: false
      t.string   "token",             null: false
      t.integer  "expires_in",        null: false
      t.text     "redirect_uri",      null: false
      t.datetime "created_at",        null: false
      t.datetime "revoked_at"
      t.string   "scopes"
    end

    add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

    create_table "oauth_access_tokens", force: :cascade do |t|
      t.integer  "resource_owner_id"
      t.integer  "application_id"
      t.string   "token",             null: false
      t.string   "refresh_token"
      t.integer  "expires_in"
      t.datetime "revoked_at"
      t.datetime "created_at",        null: false
      t.string   "scopes"
    end

    add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
    add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

    create_table "oauth_applications", force: :cascade do |t|
      t.string   "name",                      null: false
      t.string   "uid",                       null: false
      t.string   "secret",                    null: false
      t.text     "redirect_uri",              null: false
      t.string   "scopes",       default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

    create_table "organization_data", force: :cascade do |t|
      t.integer  "organization_id", null: false
      t.text     "path_suffix",     null: false
      t.text     "collection_name", null: false
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
    end

    add_index "organization_data", ["organization_id", "collection_name"], name: "index_organization_data_on_organization_id_and_collection_name", unique: true, using: :btree
    add_index "organization_data", ["organization_id", "path_suffix"], name: "index_organization_data_on_organization_id_and_path_suffix", unique: true, using: :btree
    add_index "organization_data", ["organization_id"], name: "index_organization_data_on_organization_id", using: :btree

    create_table "organizations", force: :cascade do |t|
      t.text     "name",                                  null: false
      t.datetime "created_at",                            null: false
      t.datetime "updated_at",                            null: false
      t.integer  "default_role_id"
      t.text     "admin_url"
      t.integer  "default_report_type_id"
      t.text     "database"
      t.boolean  "has_new_button",         default: true, null: false
      t.text     "logo"
      t.text     "csv_separator",          default: "|",  null: false
    end

    add_index "organizations", ["default_role_id"], name: "index_organizations_on_default_role_id", using: :btree
    add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree

    create_table "regions", force: :cascade do |t|
      t.text     "name",          null: false
      t.text     "roman_numeral", null: false
      t.integer  "number"
      t.datetime "created_at",    null: false
      t.datetime "updated_at",    null: false
    end

    add_index "regions", ["name"], name: "index_regions_on_name", unique: true, using: :btree
    add_index "regions", ["roman_numeral"], name: "index_regions_on_roman_numeral", unique: true, using: :btree

    create_table "report_columns", force: :cascade do |t|
      t.text     "field_name"
      t.text     "column_name"
      t.integer  "position"
      t.datetime "created_at",                    null: false
      t.datetime "updated_at",                    null: false
      t.integer  "report_type_id",                null: false
      t.text     "relationship_name"
      t.integer  "data_type",         default: 1
    end

    add_index "report_columns", ["report_type_id"], name: "index_report_columns_on_report_type_id", using: :btree

    create_table "report_types", force: :cascade do |t|
      t.text     "name"
      t.integer  "organization_id"
      t.datetime "created_at",                      null: false
      t.datetime "updated_at",                      null: false
      t.text     "title_field"
      t.text     "subtitle_field"
      t.boolean  "has_nav_button",  default: false
    end

    add_index "report_types", ["organization_id"], name: "index_report_types_on_organization_id", using: :btree

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
    end

    add_index "reports", ["assigned_user_id"], name: "index_reports_on_assigned_user_id", using: :btree
    add_index "reports", ["creator_id"], name: "index_reports_on_creator_id", using: :btree
    add_index "reports", ["deleted_at"], name: "index_reports_on_deleted_at", using: :btree
    add_index "reports", ["end_location_id"], name: "index_reports_on_end_location_id", using: :btree
    add_index "reports", ["finish_location_id"], name: "index_reports_on_finish_location_id", using: :btree
    add_index "reports", ["id"], name: "index_reports_on_id", using: :btree
    add_index "reports", ["marked_location_id"], name: "index_reports_on_marked_location_id", using: :btree
    add_index "reports", ["report_type_id"], name: "index_reports_on_report_type_id", using: :btree
    add_index "reports", ["start_location_id"], name: "index_reports_on_start_location_id", using: :btree

    create_table "roles", force: :cascade do |t|
      t.integer  "organization_id", null: false
      t.text     "name",            null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "roles", ["organization_id", "name"], name: "index_roles_on_organization_id_and_name", unique: true, using: :btree
    add_index "roles", ["organization_id"], name: "index_roles_on_organization_id", using: :btree

    create_table "sections", force: :cascade do |t|
      t.integer  "position"
      t.text     "name"
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
      t.integer  "section_type_id", null: false
      t.integer  "report_type_id"
    end

    add_index "sections", ["report_type_id"], name: "index_sections_on_report_type_id", using: :btree

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
    end

    add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
    add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
    add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree
    add_index "users", ["rut"], name: "index_users_on_rut", unique: true, using: :btree

    add_foreign_key "batch_uploads", "users"
    add_foreign_key "categories", "organizations"
    add_foreign_key "checkins", "users"
    add_foreign_key "communes", "regions"
    add_foreign_key "data_parts", "data_parts"
    add_foreign_key "data_parts", "organizations"
    add_foreign_key "data_parts", "sections"
    add_foreign_key "devices", "users"
    add_foreign_key "images", "categories"
    add_foreign_key "images", "reports"
    add_foreign_key "invitations", "roles"
    add_foreign_key "menu_items", "menu_sections"
    add_foreign_key "menu_sections", "organizations"
    add_foreign_key "organization_data", "organizations"
    add_foreign_key "report_columns", "report_types"
    add_foreign_key "report_types", "organizations"
    add_foreign_key "reports", "report_types"
    add_foreign_key "roles", "organizations"
    add_foreign_key "sections", "report_types"
    add_foreign_key "users", "roles"

  end
end
