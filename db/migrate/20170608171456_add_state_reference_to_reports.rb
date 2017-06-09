class AddStateReferenceToReports < ActiveRecord::Migration[5.0]
  def change
    add_reference :reports, :state, foreign_key: true
    Report.with_deleted.all.each do |report|
      if report.state.nil?
        report.update_column :state_id, report.report_type.initial_state_id
      end
    end
    change_column :reports, :state_id, :integer, null: false
  end
end
