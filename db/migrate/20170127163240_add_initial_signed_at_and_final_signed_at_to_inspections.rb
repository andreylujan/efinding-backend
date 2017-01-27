class AddInitialSignedAtAndFinalSignedAtToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :initial_signed_at, :datetime
    add_column :inspections, :final_signed_at, :datetime
  end
end
