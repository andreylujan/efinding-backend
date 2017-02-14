# -*- encoding : utf-8 -*-
class CreatePeople < ActiveRecord::Migration[5.0]
  def change
    create_table :people do |t|
      t.text :rut
      t.text :name

      t.timestamps
    end
    add_index :people, :rut
  end
end
