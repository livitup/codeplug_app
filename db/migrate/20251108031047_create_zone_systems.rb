class CreateZoneSystems < ActiveRecord::Migration[8.1]
  def change
    create_table :zone_systems do |t|
      t.references :zone, null: false, foreign_key: true
      t.references :system, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :zone_systems, [ :zone_id, :system_id ], unique: true
    add_index :zone_systems, [ :zone_id, :position ], unique: true
  end
end
