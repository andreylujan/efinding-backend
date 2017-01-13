# -*- encoding : utf-8 -*-
class CreateInspections < ActiveRecord::Migration[5.0]
  def change
    create_table :inspections do |t|
      t.references :construction, foreign_key: true

      t.timestamps
    end
  end
end
