class AddCreatorIdToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :creator_id, :integer
    add_index :inspections, :creator_id
    add_foreign_key :inspections, :users, column: :creator_id
  end
end
