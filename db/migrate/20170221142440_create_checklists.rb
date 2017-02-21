class CreateChecklists < ActiveRecord::Migration[5.0]
  def change
    create_table :checklists do |t|
      t.integer :report_type_id
      t.text :name
      t.json :sections, null: false, default: []

      t.timestamps
    end
    add_index :checklists, :report_type_id, unique: true
    add_foreign_key :checklists, :report_types
  end
end
