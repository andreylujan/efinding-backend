# -*- encoding : utf-8 -*-
class RemoveDataPartIdFromDataParts < ActiveRecord::Migration[5.0]
  def change
    remove_column :data_parts, :data_part_id, :integer
  end
end
