# -*- encoding : utf-8 -*-
class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.text :name
      t.references :organization, foreign_key: true

      t.timestamps
    end
    add_index :companies, [ :name, :organization_id ], unique: true
  end
end
