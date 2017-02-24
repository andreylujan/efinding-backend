class RemovePeople < ActiveRecord::Migration[5.0]
  def change
  	drop_table :constructions_people
  	remove_column :constructions, :visitor_id, :integer
  	drop_table :people
  end
end
