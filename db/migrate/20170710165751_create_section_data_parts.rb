# -*- encoding : utf-8 -*-
class CreateSectionDataParts < ActiveRecord::Migration[5.0]
  def change
    create_table :section_data_parts do |t|
      t.references :section, foreign_key: true, null: false
      t.references :data_part, foreign_key: true, null: false
      t.boolean :editable, default: true, null: false
      t.integer :position, default: 1, null: false

      t.timestamps
    end
    add_index :section_data_parts, [ :section_id, :data_part_id ], unique: true
  end
end
