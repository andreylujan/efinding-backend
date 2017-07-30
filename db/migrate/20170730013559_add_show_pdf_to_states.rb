# -*- encoding : utf-8 -*-
class AddShowPdfToStates < ActiveRecord::Migration[5.0]
  def change
    add_column :states, :show_pdf, :boolean, null: false, default: true
  end
end
