class AddIsSuperuserToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_superuser, :boolean, null: false, default: false
  end
end
