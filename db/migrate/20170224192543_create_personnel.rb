# -*- encoding : utf-8 -*-
class CreatePersonnel < ActiveRecord::Migration[5.0]
  def change
    create_table :personnel do |t|
      t.references :organization, foreign_key: true, null: false
      t.text :rut, null: false
      t.text :name, null: false

      t.timestamps
    end
    add_index :personnel, :rut
    add_index :personnel, [ :organization_id, :rut ], unique: true
  end
end
