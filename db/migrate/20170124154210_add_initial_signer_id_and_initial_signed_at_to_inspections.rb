# -*- encoding : utf-8 -*-
class AddInitialSignerIdAndInitialSignedAtToInspections < ActiveRecord::Migration[5.0]
  def change
    add_column :inspections, :signer_id, :integer
    add_column :inspections, :signed_at, :datetime
    add_foreign_key :inspections, :users, column: :signer_id
  end
end
