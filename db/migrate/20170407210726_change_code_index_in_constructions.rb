# -*- encoding : utf-8 -*-
class ChangeCodeIndexInConstructions < ActiveRecord::Migration[5.0]
  def change
  	remove_index :constructions, :code
  	add_index :constructions, [ :company_id, :code ], unique: true
  end
end
