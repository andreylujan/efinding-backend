class AddCollectionIdToMenuItems < ActiveRecord::Migration[5.0]
  def change
    add_column :menu_items, :collection_id, :integer
    add_index :menu_items, :collection_id
    add_foreign_key :menu_items, :collections
  end
end
