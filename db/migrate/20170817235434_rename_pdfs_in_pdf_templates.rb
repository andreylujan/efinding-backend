class RenamePdfsInPdfTemplates < ActiveRecord::Migration[5.0]
  def change
  	rename_column :pdf_templates, :pdf, :template
  end
end
