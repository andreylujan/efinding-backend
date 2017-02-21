class RemoveChecklistsIdFromChecklistReports < ActiveRecord::Migration[5.0]
  def change
    remove_column :checklist_reports, :checklists_id, :integer
  end
end
