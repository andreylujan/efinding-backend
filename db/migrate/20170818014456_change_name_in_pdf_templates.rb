# -*- encoding : utf-8 -*-
class ChangeNameInPdfTemplates < ActiveRecord::Migration[5.0]
  def change
  	rename_column :pdf_templates, :title, :name
  end
end
