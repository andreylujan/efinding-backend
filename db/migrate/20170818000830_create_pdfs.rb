# -*- encoding : utf-8 -*-
class CreatePdfs < ActiveRecord::Migration[5.0]
  def change
    create_table :pdfs do |t|
      t.text :pdf
      t.references :pdf_template, foreign_key: true, null: false
      t.uuid :report_id, null: false

      t.timestamps
    end
    add_foreign_key :pdfs, :reports
  end
end
