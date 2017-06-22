# -*- encoding : utf-8 -*-
class AddDefaultReportTypeIdToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :default_report_type_id, :integer
    add_index :organizations, :default_report_type_id
    add_foreign_key :organizations, :report_types, column: :default_report_type_id
    Organization.all.each do |org|
      if org.default_report_type.nil?
        org.update_column :default_report_type_id, org.report_types.first.id
      end
    end
  end
end
