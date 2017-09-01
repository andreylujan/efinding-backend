class AddIsProcessedToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :is_processed, :boolean, null: false, default: false
  end
end
