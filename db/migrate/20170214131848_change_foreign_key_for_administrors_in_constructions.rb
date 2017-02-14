# -*- encoding : utf-8 -*-
class ChangeForeignKeyForAdministrorsInConstructions < ActiveRecord::Migration[5.0]
  def change
  	Construction.all.each do |construction|
  		construction.update_attribute(:administrator, nil)
  	end
  	remove_foreign_key :constructions, :users # , column: :administrator_id
  	add_foreign_key :constructions, :people, column: :administrator_id
  end
end
