class CreateJoinTableConstructionContractor < ActiveRecord::Migration[5.0]
  def change
    create_join_table :constructions, :contractors do |t|
      # t.index [:construction_id, :contractor_id]
      # t.index [:contractor_id, :construction_id]
    end
  end
end
