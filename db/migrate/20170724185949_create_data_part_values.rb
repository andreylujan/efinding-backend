# -*- encoding : utf-8 -*-
class CreateDataPartValues < ActiveRecord::Migration[5.0]
  def change
    create_table :data_part_values do |t|
      t.references :collection_item, foreign_key: true
      t.references :data_part, foreign_key: true, null: false
      t.uuid :report_id
      t.timestamps
    end
    add_index :data_part_values, :report_id
    add_foreign_key :data_part_values, :reports
    add_index :data_part_values, [ :data_part_id, :report_id ], unique: true
  end
end
