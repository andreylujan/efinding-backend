class CreateContractors < ActiveRecord::Migration[5.0]
  def change
    create_table :contractors do |t|
      t.text :name, null: false
      t.text :rut, null: false
      t.references :organization, foreign_key: true, null: false
      t.timestamps
    end
    add_index :contractors, [ :organization_id, :rut ], unique: true
  end
end
