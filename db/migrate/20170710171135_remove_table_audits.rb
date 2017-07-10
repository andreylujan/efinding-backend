class RemoveTableAudits < ActiveRecord::Migration[5.0]
  def change
  	drop_table :audits
  end
end
