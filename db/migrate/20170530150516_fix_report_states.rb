class FixReportStates < ActiveRecord::Migration[5.0]
  def change
  	Report.all.each do |report|
  		state = report.state
  		if report.state == "0"
  			state = "unchecked"
  		elsif report.state == "1"
  			state = "pending"
  		elsif report.state == "2"
  			state = "resolved"
  		end
  		report.update_column :state, state
  	end
  end
end
