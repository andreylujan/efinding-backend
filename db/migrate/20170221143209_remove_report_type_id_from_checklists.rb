class RemoveReportTypeIdFromChecklists < ActiveRecord::Migration[5.0]
  def change
    remove_column :checklists, :report_type_id, :integer
  end
end
