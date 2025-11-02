class CreateSystemNetworks < ActiveRecord::Migration[8.1]
  def change
    create_table :system_networks do |t|
      t.references :system, null: false, foreign_key: true
      t.references :network, null: false, foreign_key: true

      t.timestamps
    end

    add_index :system_networks, [ :system_id, :network_id ], unique: true
  end
end
