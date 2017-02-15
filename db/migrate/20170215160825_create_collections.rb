# -*- encoding : utf-8 -*-
class CreateCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :collections do |t|
      t.text :name
      t.integer :parent_collection_id

      t.timestamps
    end
    add_index :collections, :parent_collection_id
    add_foreign_key :collections, :collections, column: :parent_collection_id
  end
end
