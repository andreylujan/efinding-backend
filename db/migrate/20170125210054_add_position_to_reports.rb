# -*- encoding : utf-8 -*-
class AddPositionToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :position, :integer
  end
end
