# -*- encoding : utf-8 -*-
class CreateJoinTableInspectionUser < ActiveRecord::Migration[5.0]
  def change
    create_join_table :inspections, :users do |t|
      t.index [:inspection_id, :user_id]
      t.index [:user_id, :inspection_id]
    end
  end
end
