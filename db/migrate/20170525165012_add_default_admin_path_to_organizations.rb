# -*- encoding : utf-8 -*-
class AddDefaultAdminPathToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :default_admin_path, :text
  end
end
