# -*- encoding : utf-8 -*-
class AddDeletedAtToConstructions < ActiveRecord::Migration[5.0]
  def change
    add_column :constructions, :deleted_at, :datetime
    add_index :constructions, :deleted_at
  end
end
