# -*- encoding : utf-8 -*-
class AddDeletedAtToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :deleted_at, :datetime
    add_index :inspections, :deleted_at
  end
end
