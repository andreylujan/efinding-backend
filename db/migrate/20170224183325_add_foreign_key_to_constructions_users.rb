class AddForeignKeyToConstructionsUsers < ActiveRecord::Migration[5.0]
  def change
  	remove_foreign_key :constructions, :people
  	add_foreign_key :constructions, :users, column: :administrator_id
  end
end
