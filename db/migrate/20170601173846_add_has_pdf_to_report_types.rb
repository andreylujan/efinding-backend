# -*- encoding : utf-8 -*-
class AddHasPdfToReportTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :report_types, :has_pdf, :boolean, null: false, default: true
  end
end
