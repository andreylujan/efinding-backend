class AddAssignsUserToDataParts < ActiveRecord::Migration[5.0]
  def change
  	add_column :data_parts, :assigns_user, :boolean, null: false, default: false
  end
end
