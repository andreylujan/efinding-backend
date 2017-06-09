class AddStateToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :state, :text
  end
end
