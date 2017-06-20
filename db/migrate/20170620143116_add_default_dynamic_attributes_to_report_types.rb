# -*- encoding : utf-8 -*-
class AddDefaultDynamicAttributesToReportTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :report_types, :default_dynamic_attributes, :json, null: false, default: {}
  end
end
