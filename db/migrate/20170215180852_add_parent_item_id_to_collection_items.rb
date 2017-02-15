class AddParentItemIdToCollectionItems < ActiveRecord::Migration[5.0]
  def change
    add_column :collection_items, :parent_item_id, :integer
    add_index :collection_items, :parent_item_id
    add_foreign_key :collection_items, :collection_items, column: :parent_item_id
  end
end
