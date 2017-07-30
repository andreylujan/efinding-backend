# -*- encoding : utf-8 -*-
class ChangeJsonTypesInOtherTables < ActiveRecord::Migration[5.0]
  def change
  	change_column :sections, :config, :jsonb
  	change_column :data_parts, :config, :jsonb
  	change_column :checklist_reports, :checklist_data, :jsonb
  	change_column :checklists, :sections, :jsonb
  end
end
