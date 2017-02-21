class AddChecklistReferenceToChecklistReports < ActiveRecord::Migration[5.0]
  def change
    add_reference :checklist_reports, :checklist, foreign_key: true
  end
end
