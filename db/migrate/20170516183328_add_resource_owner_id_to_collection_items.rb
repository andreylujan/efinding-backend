class AddResourceOwnerIdToCollectionItems < ActiveRecord::Migration[5.0]
  def change
    add_column :collection_items, :resource_owner_id, :integer
    add_index :collection_items, :resource_owner_id
  end
end
