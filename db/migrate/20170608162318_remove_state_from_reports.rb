# -*- encoding : utf-8 -*-
class RemoveStateFromReports < ActiveRecord::Migration[5.0]
  def change
    remove_column :reports, :state, :text
  end
end
