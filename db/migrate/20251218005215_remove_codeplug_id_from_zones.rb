class RemoveCodeplugIdFromZones < ActiveRecord::Migration[8.1]
  def change
    # Remove the foreign key constraint first
    remove_foreign_key :zones, :codeplugs

    # Remove the index
    remove_index :zones, :codeplug_id

    # Remove the column
    remove_column :zones, :codeplug_id, :bigint
  end
end
