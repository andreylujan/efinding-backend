class AddColumnToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :role_id, :integer, default: 0 , null: false
    Report.reset_column_information
    reports = Report.all
    reports.map do |r|
      r.update_column :role_id, r.creator.role_id
    end
  end
end
