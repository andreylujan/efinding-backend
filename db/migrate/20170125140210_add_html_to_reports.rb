class AddHtmlToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :html, :text
  end
end
