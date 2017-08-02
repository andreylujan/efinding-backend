class AddChecklistReportTypeToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :checklist_report_type_id, :integer
    add_foreign_key :organizations, :report_types, column: :checklist_report_type_id
  end
end
