class AddInitialLocationImageAndFinalLocationImageToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :initial_location_image, :text
    add_column :reports, :final_location_image, :text
  end
end
