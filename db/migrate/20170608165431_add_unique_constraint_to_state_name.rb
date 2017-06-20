# -*- encoding : utf-8 -*-
class AddUniqueConstraintToStateName < ActiveRecord::Migration[5.0]
  def change
  	add_index :states, [ :name, :report_type_id ], unique: true
  end
end
