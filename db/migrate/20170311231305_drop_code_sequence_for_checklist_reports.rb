# -*- encoding : utf-8 -*-
class DropCodeSequenceForChecklistReports < ActiveRecord::Migration[5.0]
  def change
  	ActiveRecord::Base.connection.execute("DROP SEQUENCE IF EXISTS checklist_reports_code_seq")
  end
end
