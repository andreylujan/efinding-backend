# -*- encoding : utf-8 -*-
class MigrateDefaultDynamicAttributesInReportTypes < ActiveRecord::Migration[5.0]
  def change
  	change_column :report_types, :default_dynamic_attributes, :jsonb, null: false, default: {}
  end
end
