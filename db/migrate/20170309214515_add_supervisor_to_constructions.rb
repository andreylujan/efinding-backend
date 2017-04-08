# -*- encoding : utf-8 -*-
class AddSupervisorToConstructions < ActiveRecord::Migration[5.0]
  def change
    add_column :constructions, :supervisor_id, :integer
    add_index :constructions, :supervisor_id
    add_foreign_key :constructions, :users, column: :supervisor_id
  end
end
