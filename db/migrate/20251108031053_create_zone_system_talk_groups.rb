class CreateZoneSystemTalkGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :zone_system_talk_groups do |t|
      t.references :zone_system, null: false, foreign_key: true
      t.references :system_talk_group, null: false, foreign_key: true

      t.timestamps
    end

    add_index :zone_system_talk_groups, [ :zone_system_id, :system_talk_group_id ],
              unique: true, name: "index_zstg_on_zone_system_and_system_talk_group"
  end
end
