class AddDeleteToCollectionItems < ActiveRecord::Migration[5.0]
  def change
    add_column :collection_items, :deleted_at, :datetime
  end
end
