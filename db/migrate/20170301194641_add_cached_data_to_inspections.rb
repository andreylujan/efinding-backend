# -*- encoding : utf-8 -*-
class AddCachedDataToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :cached_data, :json, default: {}
  end
end
