class RenamePdfs < ActiveRecord::Migration[5.0]
  def change
  	rename_table :pdfs, :pdf_templates
  end
end
