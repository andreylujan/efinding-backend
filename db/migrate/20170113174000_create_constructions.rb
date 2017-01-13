# -*- encoding : utf-8 -*-
class CreateConstructions < ActiveRecord::Migration[5.0]
  def change
    create_table :constructions do |t|
      t.references :organization, foreign_key: true
      t.text :name, null: false

      t.timestamps
    end
    add_index :constructions, [ :name, :organization_id ], unique: true
  end
end
