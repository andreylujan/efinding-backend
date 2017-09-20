class AddAutoAssignedOnCreation < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :auto_assigned_on_creation, :boolean, null: false, default: true
    add_index :reports, :auto_assigned_on_creation
  end
end
