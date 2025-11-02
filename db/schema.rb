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

ActiveRecord::Schema[8.1].define(version: 2025_11_02_015151) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "manufacturers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_manufacturers_on_name", unique: true
  end

  create_table "radio_models", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "frequency_ranges"
    t.integer "long_channel_name_length"
    t.integer "long_zone_name_length"
    t.bigint "manufacturer_id", null: false
    t.integer "max_channels_per_zone"
    t.integer "max_zones"
    t.string "name", null: false
    t.integer "short_channel_name_length"
    t.integer "short_zone_name_length"
    t.text "supported_modes", null: false
    t.datetime "updated_at", null: false
    t.index ["manufacturer_id", "name"], name: "index_radio_models_on_manufacturer_id_and_name", unique: true
    t.index ["manufacturer_id"], name: "index_radio_models_on_manufacturer_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "callsign"
    t.datetime "created_at", null: false
    t.string "default_power_level"
    t.string "email", null: false
    t.string "measurement_preference"
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "radio_models", "manufacturers"
end
