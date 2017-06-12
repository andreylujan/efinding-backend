class AddMapTypeToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :map_type, :integer, null: false, default: 0
  end
end
