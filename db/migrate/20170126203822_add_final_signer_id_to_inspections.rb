class AddFinalSignerIdToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :final_signer_id, :integer
    add_foreign_key :inspections, :users, column: :final_signer_id
  end
end
