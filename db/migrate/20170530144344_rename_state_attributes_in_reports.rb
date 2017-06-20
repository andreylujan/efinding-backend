# -*- encoding : utf-8 -*-
class RenameStateAttributesInReports < ActiveRecord::Migration[5.0]
  def change
  	remove_column :reports, :state
  	Report.reset_column_information
  	rename_column :reports, :state_text, :state
  end
end
