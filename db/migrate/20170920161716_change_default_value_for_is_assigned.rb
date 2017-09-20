class ChangeDefaultValueForIsAssigned < ActiveRecord::Migration[5.0]
  def change
  	remove_column :reports, :is_assigned
  	add_column :reports, :is_assigned, :boolean, null: false, default: false
  	add_index :reports, :is_assigned
  end
end
