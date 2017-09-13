# -*- encoding : utf-8 -*-
class AddDefaultColorValueToStates < ActiveRecord::Migration[5.0]
  def change
  	change_column :states, :color, :text, null: false, default: '#7ECECB'
  end
end
