# -*- encoding : utf-8 -*-
class AddCodeIndexAndNullConstraintToChecklistReports < ActiveRecord::Migration[5.0]
  def change
  	change_column :checklist_reports, :code, :integer, null: false
  	add_index :checklist_reports, [ :construction_id, :code ], unique: true
  end
end
