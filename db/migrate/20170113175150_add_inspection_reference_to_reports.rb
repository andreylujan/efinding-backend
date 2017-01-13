# -*- encoding : utf-8 -*-
class AddInspectionReferenceToReports < ActiveRecord::Migration[5.0]
  def change
    add_reference :reports, :inspection, foreign_key: true
  end
end
