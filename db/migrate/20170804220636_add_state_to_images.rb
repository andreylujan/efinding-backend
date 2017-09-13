# -*- encoding : utf-8 -*-
class AddStateToImages < ActiveRecord::Migration[5.0]
  def change
    add_reference :images, :state, foreign_key: true
  end
end
