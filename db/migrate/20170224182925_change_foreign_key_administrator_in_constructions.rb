class ChangeForeignKeyAdministratorInConstructions < ActiveRecord::Migration[5.0]
  def change
  	Construction.all.each do |construction|
  		construction.update_attributes! administrator: nil
  	end
  	remove_foreign_key :constructions, :people  	
  end
end
