# -*- encoding : utf-8 -*-
class AddSelectedToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :selected, :boolean, null: false, default: false
  end
end
