class AddCodeAndParentCodeToCollectionItems < ActiveRecord::Migration[5.0]
  def change
    add_column :collection_items, :code, :text
    add_column :collection_items, :parent_code, :text
    add_index :collection_items, [ :collection_id, :code ], unique: true
    CollectionItem.all.each do |item|
      item.update_attributes! code: item.id.to_s
      item.update_attributes! parent_code: item.parent_item_id unless item.parent_item_id.nil?
    end
  end
end
