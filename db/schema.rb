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

ActiveRecord::Schema[8.1].define(version: 2025_11_02_232504) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "analog_mode_details", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "codeplug_layouts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "layout_definition", null: false
    t.string "name", null: false
    t.bigint "radio_model_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["radio_model_id", "name"], name: "index_codeplug_layouts_on_radio_model_id_and_name"
    t.index ["radio_model_id"], name: "index_codeplug_layouts_on_radio_model_id"
    t.index ["user_id"], name: "index_codeplug_layouts_on_user_id"
  end

  create_table "dmr_mode_details", force: :cascade do |t|
    t.integer "color_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "manufacturers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_manufacturers_on_name", unique: true
  end

  create_table "networks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "network_type"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["name"], name: "index_networks_on_name", unique: true
  end

  create_table "p25_mode_details", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nac", null: false
    t.datetime "updated_at", null: false
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

  create_table "system_networks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "network_id", null: false
    t.bigint "system_id", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id"], name: "index_system_networks_on_network_id"
    t.index ["system_id", "network_id"], name: "index_system_networks_on_system_id_and_network_id", unique: true
    t.index ["system_id"], name: "index_system_networks_on_system_id"
  end

  create_table "systems", force: :cascade do |t|
    t.string "bandwidth"
    t.string "city"
    t.string "county"
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "mode", null: false
    t.bigint "mode_detail_id", null: false
    t.string "mode_detail_type", null: false
    t.string "name", null: false
    t.decimal "rx_frequency", precision: 10, scale: 6, null: false
    t.string "rx_tone_value"
    t.string "state"
    t.boolean "supports_rx_tone", default: false
    t.boolean "supports_tx_tone", default: false
    t.decimal "tx_frequency", precision: 10, scale: 6, null: false
    t.string "tx_tone_value"
    t.datetime "updated_at", null: false
    t.index ["latitude", "longitude"], name: "index_systems_on_latitude_and_longitude"
    t.index ["mode"], name: "index_systems_on_mode"
    t.index ["mode_detail_type", "mode_detail_id"], name: "index_systems_on_mode_detail"
  end

  create_table "talk_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "network_id", null: false
    t.string "talkgroup_number", null: false
    t.datetime "updated_at", null: false
    t.index ["network_id", "talkgroup_number"], name: "index_talk_groups_on_network_id_and_talkgroup_number", unique: true
    t.index ["network_id"], name: "index_talk_groups_on_network_id"
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

  add_foreign_key "codeplug_layouts", "radio_models"
  add_foreign_key "codeplug_layouts", "users"
  add_foreign_key "radio_models", "manufacturers"
  add_foreign_key "system_networks", "networks"
  add_foreign_key "system_networks", "systems"
  add_foreign_key "talk_groups", "networks"
end
