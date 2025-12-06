class AddOwnershipToRadioModels < ActiveRecord::Migration[8.1]
  def change
    add_reference :radio_models, :user, null: true, foreign_key: true
    add_column :radio_models, :system_record, :boolean, default: false, null: false

    # Convert existing records to system records
    reversible do |dir|
      dir.up do
        execute "UPDATE radio_models SET system_record = true"
      end
    end
  end
end
