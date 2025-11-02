class CreateTalkGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :talk_groups do |t|
      t.references :network, null: false, foreign_key: true
      t.string :name, null: false
      t.string :talkgroup_number, null: false
      t.text :description

      t.timestamps
    end

    add_index :talk_groups, [ :network_id, :talkgroup_number ], unique: true
  end
end
