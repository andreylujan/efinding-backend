# -*- encoding : utf-8 -*-
class AddIsSuperuserToInvitations < ActiveRecord::Migration[5.0]
  def change
    add_column :invitations, :is_superuser, :boolean, null: false, default: false
  end
end
