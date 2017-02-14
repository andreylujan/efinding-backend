# -*- encoding : utf-8 -*-
class AddStateToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :state, :text
  end
end
