class RenameSignerIdInInspectionsToInitialSignerId < ActiveRecord::Migration[5.0]
  def change
  	rename_column :inspections, :signer_id, :initial_signer_id
  end
end
