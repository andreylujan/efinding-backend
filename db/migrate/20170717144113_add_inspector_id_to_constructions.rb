# -*- encoding : utf-8 -*-
class AddInspectorIdToConstructions < ActiveRecord::Migration[5.0]
  def change
    add_column :constructions, :inspector_id, :integer
    add_index :constructions, :inspector_id
  end
end
