class RemoveMarkedLocationIdAndStartLocationIdAndFinishLocationIdAndEndLocationIdFromReports < ActiveRecord::Migration[5.0]
  def change
    remove_column :reports, :start_location_id, :integer
    remove_column :reports, :marked_location_id, :integer
    remove_column :reports, :finish_location_id, :integer
    remove_column :reports, :end_location_id, :integer
  end
end
