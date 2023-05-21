# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_05_21_080848) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "countries", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "repeater_searches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.boolean "band_10m"
    t.boolean "band_6m"
    t.boolean "band_4m"
    t.boolean "band_2m"
    t.boolean "band_70cm"
    t.boolean "band_23cm"
    t.boolean "fm"
    t.boolean "dstar"
    t.boolean "fusion"
    t.boolean "dmr"
    t.boolean "nxdn"
    t.boolean "distance_to_coordinates"
    t.integer "distance"
    t.string "distance_unit"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["user_id"], name: "index_repeater_searches_on_user_id"
  end

  create_table "repeaters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "call_sign"
    t.string "band"
    t.string "channel"
    t.string "keeper"
    t.boolean "operational"
    t.text "notes"
    t.decimal "tx_frequency"
    t.decimal "rx_frequency"
    t.boolean "fm"
    t.string "access_method"
    t.decimal "ctcss_tone"
    t.boolean "tone_sql"
    t.boolean "dstar"
    t.boolean "fusion"
    t.boolean "dmr"
    t.integer "dmr_color_code"
    t.string "dmr_network"
    t.boolean "nxdn"
    t.geography "location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "grid_square"
    t.string "utc_offset"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "redistribution_limitations"
    t.string "address"
    t.string "locality"
    t.string "region"
    t.string "post_code"
    t.string "country_id"
    t.string "web_site"
    t.string "external_id"
    t.boolean "p25"
    t.boolean "tetra"
    t.decimal "tx_power"
    t.string "tx_antenna"
    t.string "tx_antenna_polarization"
    t.string "rx_antenna"
    t.string "rx_antenna_polarization"
    t.decimal "altitude_asl"
    t.decimal "altitude_agl"
    t.string "bearing"
    t.index ["call_sign"], name: "index_repeaters_on_call_sign"
    t.index ["country_id"], name: "index_repeaters_on_country_id"
    t.index ["location"], name: "index_repeaters_on_location", using: :gist
  end

  create_table "suggested_repeaters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "submitter_name"
    t.string "submitter_email"
    t.string "submitter_call_sign"
    t.boolean "submitter_keeper"
    t.text "submitter_notes"
    t.string "name"
    t.string "call_sign"
    t.string "band"
    t.string "channel"
    t.string "keeper"
    t.text "notes"
    t.string "web_site"
    t.string "tx_frequency"
    t.string "rx_frequency"
    t.boolean "fm"
    t.string "access_method"
    t.string "ctcss_tone"
    t.boolean "tone_sql"
    t.boolean "dstar"
    t.boolean "fusion"
    t.boolean "dmr"
    t.string "dmr_color_code"
    t.string "dmr_network"
    t.boolean "nxdn"
    t.string "latitude"
    t.string "longitude"
    t.string "grid_square"
    t.text "private_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.string "locality"
    t.string "region"
    t.string "post_code"
    t.string "country"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "repeater_searches", "users"
  add_foreign_key "repeaters", "countries"
end
