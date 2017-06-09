class RemoveStateInReports < ActiveRecord::Migration[5.0]
  def change
  	remove_column :reports, :state
  end
end
