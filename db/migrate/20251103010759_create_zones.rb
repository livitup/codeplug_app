class CreateZones < ActiveRecord::Migration[8.1]
  def change
    create_table :zones do |t|
      t.references :codeplug, null: false, foreign_key: true
      t.string :name, null: false
      t.string :long_name
      t.string :short_name

      t.timestamps
    end
  end
end
