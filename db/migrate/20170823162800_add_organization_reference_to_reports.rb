# -*- encoding : utf-8 -*-
class AddOrganizationReferenceToReports < ActiveRecord::Migration[5.0]
  def change
    add_reference :reports, :organization, foreign_key: true
    Report.with_deleted.all.each do |report|
    	report.update_column :organization_id, report.creator.organization_id
    end
    change_column :reports, :organization_id, :integer, null: false
  end
end
