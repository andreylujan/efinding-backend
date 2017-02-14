# -*- encoding : utf-8 -*-
class AddFieldChiefIdAndExpertIdToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :field_chief_id, :integer
    add_column :inspections, :expert_id, :integer
    add_foreign_key :inspections, :users, column: :field_chief_id
    add_foreign_key :inspections, :users, column: :expert_id
  end
end
