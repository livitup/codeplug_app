class CreateCodeplugs < ActiveRecord::Migration[8.1]
  def change
    create_table :codeplugs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :public, default: false, null: false

      t.timestamps
    end
  end
end
