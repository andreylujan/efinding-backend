# -*- encoding : utf-8 -*-
class RemoveExpertIdAndFieldChiefIdFromInspections < ActiveRecord::Migration[5.0]
  def change
    remove_column :inspections, :expert_id, :integer
    remove_column :inspections, :field_chief_id, :integer
  end
end
