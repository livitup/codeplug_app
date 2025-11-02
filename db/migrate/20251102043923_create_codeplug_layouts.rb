class CreateCodeplugLayouts < ActiveRecord::Migration[8.1]
  def change
    create_table :codeplug_layouts do |t|
      t.references :radio_model, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :name, null: false
      t.text :layout_definition, null: false

      t.timestamps
    end

    add_index :codeplug_layouts, [ :radio_model_id, :name ]
  end
end
