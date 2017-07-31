# -*- encoding : utf-8 -*-
class AddStoreIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :store_id, :integer
    add_index :users, :store_id
  end
end
