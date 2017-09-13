# -*- encoding : utf-8 -*-
class AddTimeZoneToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :time_zone, :text, null: false, default: "Chile/Continental"
  end
end
