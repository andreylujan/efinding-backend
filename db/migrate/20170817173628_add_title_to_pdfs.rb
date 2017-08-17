class AddTitleToPdfs < ActiveRecord::Migration[5.0]
  def change
    add_column :pdfs, :title, :text
  end
end
