# -*- encoding : utf-8 -*-
class AddAppNameToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :app_name, :integer, null: false, default: 0
  end
end
