class CreateChannels < ActiveRecord::Migration[8.1]
  def change
    create_table :channels do |t|
      t.references :codeplug, null: false, foreign_key: true
      t.references :system, null: false, foreign_key: true
      t.references :system_talk_group, null: true, foreign_key: true
      t.string :name, null: false
      t.string :long_name
      t.string :short_name
      t.string :power_level
      t.string :bandwidth
      t.string :tone_mode, default: "none", null: false
      t.string :transmit_permission, default: "allow", null: false

      t.timestamps
    end
  end
end
