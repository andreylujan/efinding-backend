# -*- encoding : utf-8 -*-
class AddInitialLocationIdAndFinalLocationIdToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :initial_location_id, :integer
    add_column :reports, :final_location_id, :integer
    add_foreign_key :reports, :locations, column: :initial_location_id
    add_foreign_key :reports, :locations, column: :final_location_id
  end
end
