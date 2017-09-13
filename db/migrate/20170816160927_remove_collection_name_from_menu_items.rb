# -*- encoding : utf-8 -*-
class RemoveCollectionNameFromMenuItems < ActiveRecord::Migration[5.0]
  def change
    remove_column :menu_items, :collection_name, :text
  end
end
