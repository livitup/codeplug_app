class CreateP25ModeDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :p25_mode_details do |t|
      t.string :nac, null: false

      t.timestamps
    end
  end
end
