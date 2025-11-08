class CreateCodeplugZones < ActiveRecord::Migration[8.1]
  def change
    create_table :codeplug_zones do |t|
      t.references :codeplug, null: false, foreign_key: true
      t.references :zone, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :codeplug_zones, [ :codeplug_id, :zone_id ], unique: true
    add_index :codeplug_zones, [ :codeplug_id, :position ], unique: true
  end
end
