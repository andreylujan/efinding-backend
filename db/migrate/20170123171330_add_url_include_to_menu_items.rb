class AddUrlIncludeToMenuItems < ActiveRecord::Migration[5.0]
  def change
    add_column :menu_items, :url_include, :text
  end
end
