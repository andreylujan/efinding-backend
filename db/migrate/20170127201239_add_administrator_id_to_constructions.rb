# -*- encoding : utf-8 -*-
class AddAdministratorIdToConstructions < ActiveRecord::Migration[5.0]
  def change
    add_column :constructions, :administrator_id, :integer
    add_foreign_key :constructions, :users, column: :administrator_id
  end
end
