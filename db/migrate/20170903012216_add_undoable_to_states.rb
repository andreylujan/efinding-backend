class AddUndoableToStates < ActiveRecord::Migration[5.0]
  def change
    add_column :states, :undoable, :boolean, null: false, default: false
  end
end
