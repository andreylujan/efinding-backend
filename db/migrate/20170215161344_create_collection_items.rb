# -*- encoding : utf-8 -*-
class CreateCollectionItems < ActiveRecord::Migration[5.0]
  def change
    create_table :collection_items do |t|
      t.references :collection, foreign_key: true
      t.text :name

      t.timestamps
    end
    add_index :collection_items, [ :collection_id, :name ], unique: true
    add_index :collection_items, :name
  end
end
