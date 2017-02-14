# -*- encoding : utf-8 -*-
class AddVisitorIdToConstructions < ActiveRecord::Migration[5.0]
  def change
    add_column :constructions, :visitor_id, :integer
    add_index :constructions, :visitor_id
    add_foreign_key :constructions, :people, column: :visitor_id
  end
end
