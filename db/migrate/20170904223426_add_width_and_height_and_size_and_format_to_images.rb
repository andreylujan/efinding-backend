class AddWidthAndHeightAndSizeAndFormatToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :width, :integer
    add_column :images, :height, :integer
    add_column :images, :size, :integer
    add_column :images, :format, :text
  end
end
