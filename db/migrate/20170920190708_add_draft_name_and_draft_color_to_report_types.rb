class AddDraftNameAndDraftColorToReportTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :report_types, :draft_name, :text
    add_column :report_types, :draft_color, :text
  end
end
