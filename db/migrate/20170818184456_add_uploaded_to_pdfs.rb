# -*- encoding : utf-8 -*-
class AddUploadedToPdfs < ActiveRecord::Migration[5.0]
  def change
    add_column :pdfs, :uploaded, :boolean, null: false, default: false
  end
end
