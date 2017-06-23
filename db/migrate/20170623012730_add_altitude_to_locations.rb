class AddAltitudeToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :altitude, :float
    change_column :locations, :accuracy, :float
  end
end
