# -*- encoding : utf-8 -*-
class DropRegionAndCommuneTables < ActiveRecord::Migration[5.0]
  def change
  	drop_table :communes
  	drop_table :regions
  end
end
