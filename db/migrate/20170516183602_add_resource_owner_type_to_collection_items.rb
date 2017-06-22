# -*- encoding : utf-8 -*-
class AddResourceOwnerTypeToCollectionItems < ActiveRecord::Migration[5.0]
  def change
    add_column :collection_items, :resource_owner_type, :text
    remove_index :collection_items, :resource_owner_id
    add_index :collection_items, [:resource_owner_type, :resource_owner_id], name: :resource_index
  end
end
