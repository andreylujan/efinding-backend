class ChangeStateTypeInReports < ActiveRecord::Migration[5.0]
  def change
  	add_column :reports, :state_text, :text, null: false, default: "unchecked"
  	Report.reset_column_information
  	reports = Report.all
  	reports.each do |report|
  		report.update_column :state_text, report.state.to_s
  	end
  end
end
