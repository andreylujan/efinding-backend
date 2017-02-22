class AddStartedAtToChecklistReports < ActiveRecord::Migration[5.0]
  def change
    add_column :checklist_reports, :started_at, :datetime
  end
end
