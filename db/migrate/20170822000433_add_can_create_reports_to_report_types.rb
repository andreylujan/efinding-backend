class AddCanCreateReportsToReportTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :report_types, :can_create_reports, :boolean, null: false, default: true
  end
end
