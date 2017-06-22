# -*- encoding : utf-8 -*-
class AddListIdToDataParts < ActiveRecord::Migration[5.0]
  def change
    add_column :data_parts, :list_id, :integer
    add_index :data_parts, :list_id
  end
end
