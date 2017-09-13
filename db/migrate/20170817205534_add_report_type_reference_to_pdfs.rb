# -*- encoding : utf-8 -*-
class AddReportTypeReferenceToPdfs < ActiveRecord::Migration[5.0]
  def change
    add_reference :pdfs, :report_type, foreign_key: true, null: false
    add_column :pdfs, :html, :text
  end
end
