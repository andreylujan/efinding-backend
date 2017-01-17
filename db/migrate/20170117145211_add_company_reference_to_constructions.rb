# -*- encoding : utf-8 -*-
class AddCompanyReferenceToConstructions < ActiveRecord::Migration[5.0]
  def change
    add_reference :constructions, :company, foreign_key: true
    add_index :constructions, [ :name, :company_id ], unique: true
  end
end
