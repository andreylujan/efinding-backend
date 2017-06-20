# -*- encoding : utf-8 -*-
class DropTableCategories < ActiveRecord::Migration[5.0]
  def change
  	remove_column :images, :category_id
  	drop_table :categories
  end
end
