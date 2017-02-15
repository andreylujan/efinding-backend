# -*- encoding : utf-8 -*-
class DestroyTableOrganizationData < ActiveRecord::Migration[5.0]
  def change
  	drop_table :organization_data
  end
end
