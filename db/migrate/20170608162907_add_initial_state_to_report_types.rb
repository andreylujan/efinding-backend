class AddInitialStateToReportTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :report_types, :initial_state_id, :integer
    add_index :report_types, :initial_state_id
    add_foreign_key :report_types, :states, column: :initial_state_id
    ReportType.all.each do |report_type|
      if report_type.initial_state.nil?
      	state = State.new name: "Inicial", report_type: report_type
      	report_type.initial_state = state
      	report_type.save!
      	state.save!
      end
    end
  end
end
