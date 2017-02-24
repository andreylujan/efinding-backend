class AddExpertToConstructions < ActiveRecord::Migration[5.0]
  def change
  	add_column :constructions, :expert_id, :integer, index: true
  	add_foreign_key :constructions, :users, column: :expert_id
  end
end
