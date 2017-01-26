class AddIsInitialToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :is_initial, :boolean, null: false, default: true
  end
end
