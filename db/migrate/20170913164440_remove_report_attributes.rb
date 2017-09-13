class RemoveReportAttributes < ActiveRecord::Migration[5.0]
  def change
  	remove_column :reports, :scheduled_at
  	remove_column :reports, :html
  	remove_column :reports, :resolver_id
  	remove_column :reports, :resolved_at
  	remove_column :reports, :started_at
  	remove_column :reports, :finished_at
  	remove_column :reports, :finished
  	remove_column :reports, :initial_location_image
  	remove_column :reports, :final_location_image
  	remove_column :reports, :position
  end
end
