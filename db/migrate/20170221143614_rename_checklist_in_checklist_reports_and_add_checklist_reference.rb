class RenameChecklistInChecklistReportsAndAddChecklistReference < ActiveRecord::Migration[5.0]
  def change
  	rename_column :checklist_reports, :checklist, :checklist_data
  	add_reference :checklist_reports, :checklists, foreign_key: true, null: false
  end
end
