class CreateJoinTableChecklistReportUser < ActiveRecord::Migration[5.0]
  def change
    create_table :checklist_reports_users, id: false do |t|
      t.uuid :checklist_report_id
      t.integer :user_id
      # t.index [:checklist_report_id, :user_id]
      # t.index [:user_id, :checklist_report_id]
    end
    add_index :checklist_reports_users, [ :checklist_report_id, :user_id ],
    	unique: true, name: 'checklists_users'
    add_index :checklist_reports_users, [ :user_id, :checklist_report_id ],
    	unique: true, name: 'users_checklists'

    drop_table :inspections_users
  end
end
