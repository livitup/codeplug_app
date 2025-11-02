class CreateRadioModels < ActiveRecord::Migration[8.1]
  def change
    create_table :radio_models do |t|
      t.references :manufacturer, null: false, foreign_key: true
      t.string :name, null: false
      t.text :supported_modes, null: false
      t.integer :max_zones
      t.integer :max_channels_per_zone
      t.integer :long_channel_name_length
      t.integer :short_channel_name_length
      t.integer :long_zone_name_length
      t.integer :short_zone_name_length
      t.text :frequency_ranges

      t.timestamps
    end

    add_index :radio_models, [ :manufacturer_id, :name ], unique: true
  end
end
