class AddColumRolesToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :roles, :json, default: {} , null: false
    User.reset_column_information
    users = User.all
    users.each do |user|
      roles = []
      if user.role_id.present?
        roles << {:id => user.id, :name => user.role_name, :active => true, :base => true}
        user.update_column :roles, roles
      end
    end
  end
end
