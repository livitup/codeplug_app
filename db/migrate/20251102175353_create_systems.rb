class CreateSystems < ActiveRecord::Migration[8.1]
  def change
    create_table :systems do |t|
      t.string :name, null: false
      t.string :mode, null: false
      t.decimal :tx_frequency, null: false, precision: 10, scale: 6
      t.decimal :rx_frequency, null: false, precision: 10, scale: 6
      t.string :bandwidth
      t.boolean :supports_tx_tone, default: false
      t.boolean :supports_rx_tone, default: false
      t.string :tx_tone_value
      t.string :rx_tone_value
      t.string :city
      t.string :state
      t.string :county
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.references :mode_detail, polymorphic: true, null: false

      t.timestamps
    end

    add_index :systems, :mode
    add_index :systems, [ :latitude, :longitude ]
  end
end
