# -*- encoding : utf-8 -*-
class AddPositionToCollectionItems < ActiveRecord::Migration[5.0]
  def change
    add_column :collection_items, :position, :integer
    Collection.all.each do |collection|
      collection.collection_items.order(:updated_at).each.with_index(1) do |item, index|
        item.update_column :position, index
      end
    end
  end
end
