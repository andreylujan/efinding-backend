class AddCanViewAllToRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :can_view_all, :boolean, null: false, default: false
  end
end
