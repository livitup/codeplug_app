class AddSourceZoneToChannels < ActiveRecord::Migration[8.1]
  def change
    add_reference :channels, :source_zone, null: true, foreign_key: { to_table: :zones }
  end
end
