# -*- encoding : utf-8 -*-
class ChangeRutColumnInContractors < ActiveRecord::Migration[5.0]
  def change
  	change_column :contractors, :rut, :text, null: true
  end
end
