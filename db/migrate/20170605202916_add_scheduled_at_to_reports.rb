class AddScheduledAtToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :scheduled_at, :datetime
    add_index :reports, :scheduled_at
  end
end
