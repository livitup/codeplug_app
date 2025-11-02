class CreateDmrModeDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :dmr_mode_details do |t|
      t.integer :color_code, null: false

      t.timestamps
    end
  end
end
