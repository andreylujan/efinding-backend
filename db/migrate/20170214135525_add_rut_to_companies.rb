# -*- encoding : utf-8 -*-
class AddRutToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :rut, :text
    add_index :companies, :rut
  end
end
