class AddColorToStates < ActiveRecord::Migration[5.0]
  def change
    add_column :states, :color, :text
  end
end
