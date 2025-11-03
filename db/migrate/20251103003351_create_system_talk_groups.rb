class CreateSystemTalkGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :system_talk_groups do |t|
      t.references :system, null: false, foreign_key: true
      t.references :talk_group, null: false, foreign_key: true
      t.integer :timeslot

      t.timestamps
    end

    add_index :system_talk_groups, [ :system_id, :talk_group_id, :timeslot ], unique: true, name: "index_system_talk_groups_unique"
  end
end
