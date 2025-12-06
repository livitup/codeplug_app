class AddOwnershipToManufacturers < ActiveRecord::Migration[8.1]
  def change
    add_reference :manufacturers, :user, null: true, foreign_key: true
    add_column :manufacturers, :system_record, :boolean, default: false, null: false

    # Convert existing records to system records
    reversible do |dir|
      dir.up do
        execute "UPDATE manufacturers SET system_record = true"
      end
    end
  end
end
