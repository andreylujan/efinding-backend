# -*- encoding : utf-8 -*-
class RemoveHasNavbuttonFromReportTypes < ActiveRecord::Migration[5.0]
  def change
    remove_column :report_types, :has_nav_button, :boolean
  end
end
