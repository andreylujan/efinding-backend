# -*- encoding : utf-8 -*-
class DropTableCheckins < ActiveRecord::Migration[5.0]
  def change
  	drop_table :checkins
  end
end
