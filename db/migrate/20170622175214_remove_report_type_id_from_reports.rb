class RemoveReportTypeIdFromReports < ActiveRecord::Migration[5.0]
  def change
    remove_column :reports, :report_type_id, :integer
  end
end
