class AddRoleTypeToRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :role_type, :integer
  end
end
