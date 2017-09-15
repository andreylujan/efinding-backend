class AddStartedAtAndFinishedAtToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :started_at, :datetime
    add_column :reports, :finished_at, :datetime
  end
end
