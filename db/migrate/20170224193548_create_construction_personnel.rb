class CreateConstructionPersonnel < ActiveRecord::Migration[5.0]
  def change
    create_table :construction_personnel do |t|
      t.references :construction, foreign_key: true, null: false
      t.references :personnel, foreign_key: true, null: false
      t.references :personnel_type, foreign_key: true, null: false

      t.timestamps
    end
    add_index :construction_personnel, [ :construction_id, :personnel_id, :personnel_type_id ], unique: true,
    	name: 'index_construction_personnel'
  end
end
