class CreateAnalogModeDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :analog_mode_details do |t|
      t.timestamps
    end
  end
end
