class RenameAutoAssignedOnCreationInReports < ActiveRecord::Migration[5.0]
  def change
  	rename_column :reports, :auto_assigned_on_creation, :is_assigned
  end
end
