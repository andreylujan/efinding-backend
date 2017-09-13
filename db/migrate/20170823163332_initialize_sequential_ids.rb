# -*- encoding : utf-8 -*-
class InitializeSequentialIds < ActiveRecord::Migration[5.0]
  def change
  	Organization.all.each do |org|
  	  org.reports.with_deleted.order("created_at ASC").each_with_index do |report, index|
  	  	report.update_column :sequential_id, index + 1
  	  end
  	end
  	change_column :reports, :sequential_id, :integer, null: false
  end
end
