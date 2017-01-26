class AddStateAndResolvedAtAndResolverIdToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :state, :integer, null: false, default: 0
    add_column :reports, :resolved_at, :datetime
    add_column :reports, :resolver_id, :integer
    add_foreign_key :reports, :users, column: :resolver_id
  end
end
