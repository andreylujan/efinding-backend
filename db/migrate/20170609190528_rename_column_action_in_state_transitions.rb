class RenameColumnActionInStateTransitions < ActiveRecord::Migration[5.0]
  def change
  	rename_column :state_transitions, :action, :name
  end
end
