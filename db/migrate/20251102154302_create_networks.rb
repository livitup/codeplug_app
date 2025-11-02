class CreateNetworks < ActiveRecord::Migration[8.1]
  def change
    create_table :networks do |t|
      t.string :name, null: false
      t.text :description
      t.string :website
      t.string :network_type

      t.timestamps
    end

    add_index :networks, :name, unique: true
  end
end
