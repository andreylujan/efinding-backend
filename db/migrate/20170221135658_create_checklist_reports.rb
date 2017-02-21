class CreateChecklistReports < ActiveRecord::Migration[5.0]
  def change
    enable_extension "uuid-ossp"
    create_table :checklist_reports, id: :uuid do |t|
      t.references :report_type, foreign_key: true, null: false
      t.references :construction, foreign_key: true, null: false
      t.integer :creator_id, null: false
      t.references :location, foreign_key: true, null: false
      t.text :pdf
      t.boolean :pdf_uploaded, null: false, default: false
      t.datetime :deleted_at
      t.text :html
      t.text :location_image
      t.json :checklist, null: false, default: []

      t.timestamps
    end
    add_index :checklist_reports, :creator_id
    add_index :checklist_reports, :deleted_at
    add_foreign_key :checklist_reports, :users, column: :creator_id
  end
end
