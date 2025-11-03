class CreateChannelZones < ActiveRecord::Migration[8.1]
  def change
    create_table :channel_zones do |t|
      t.references :channel, null: false, foreign_key: true
      t.references :zone, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :channel_zones, [ :zone_id, :position ], unique: true
  end
end
