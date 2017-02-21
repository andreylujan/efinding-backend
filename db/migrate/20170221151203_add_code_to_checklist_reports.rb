class AddCodeToChecklistReports < ActiveRecord::Migration[5.0]
  def change
    add_column :checklist_reports, :code, :integer
    execute "CREATE SEQUENCE checklist_reports_code_seq START 1"
  end
end
