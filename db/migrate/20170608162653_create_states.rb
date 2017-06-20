# -*- encoding : utf-8 -*-
class CreateStates < ActiveRecord::Migration[5.0]
  def change
    create_table :states do |t|
      t.text :name, null: false
      t.references :report_type, foreign_key: true, null: false
      
      t.timestamps
    end
  end
end
