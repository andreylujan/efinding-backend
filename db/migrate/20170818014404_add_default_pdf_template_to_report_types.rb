# -*- encoding : utf-8 -*-
class AddDefaultPdfTemplateToReportTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :report_types, :default_pdf_template_id, :integer
    add_index :report_types, :default_pdf_template_id
    add_foreign_key :report_types, :pdf_templates, column: :default_pdf_template_id
    remove_column :pdf_templates, :html
  end
end
