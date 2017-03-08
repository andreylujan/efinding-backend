# -*- encoding : utf-8 -*-
class CreatePersonnelTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :personnel_types do |t|
      t.references :organization, foreign_key: true, null: false
      t.text :name, null: false

      t.timestamps
    end
  end
end
