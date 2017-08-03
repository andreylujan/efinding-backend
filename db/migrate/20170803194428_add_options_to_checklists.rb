class AddOptionsToChecklists < ActiveRecord::Migration[5.0]
  def change
    add_column :checklists, :options, :jsonb, null: false, default: [ 'No aplica', 'Cumple', 'No cumple' ]
  end
end
