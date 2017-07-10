class RemoveUselessIndexOnCollectionItems < ActiveRecord::Migration[5.0]
  def change
  	remove_index :collection_items, [ :collection_id, :name ]
  end
end
