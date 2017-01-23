class AddCollectionNameToMenuItems < ActiveRecord::Migration[5.0]
  def change
    add_column :menu_items, :collection_name, :text
  end
end
