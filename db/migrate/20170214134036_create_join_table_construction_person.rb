# -*- encoding : utf-8 -*-
class CreateJoinTableConstructionPerson < ActiveRecord::Migration[5.0]
  def change
    create_join_table :constructions, :people do |t|
      t.index [:construction_id, :person_id]
      t.index [:person_id, :construction_id]
    end
  end
end
