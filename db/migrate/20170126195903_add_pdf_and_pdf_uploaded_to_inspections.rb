class AddPdfAndPdfUploadedToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :pdf, :text
    add_column :inspections, :pdf_uploaded, :boolean, null: false, default: false
  end
end
