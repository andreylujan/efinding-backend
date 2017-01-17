class AddResolvedAtToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :resolved_at, :datetime
  end
end
