class RefactorZonesToBeStandalone < ActiveRecord::Migration[8.1]
  def change
    # Add user_id to zones (owner of the zone)
    add_reference :zones, :user, null: false, foreign_key: true

    # Add public flag (default to false)
    add_column :zones, :public, :boolean, null: false, default: false

    # Make codeplug_id nullable (zones are now standalone and can be shared across codeplugs)
    change_column_null :zones, :codeplug_id, true
  end
end
