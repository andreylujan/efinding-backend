class AddOrganizationReferenceToChecklists < ActiveRecord::Migration[5.0]
  def change
    add_reference :checklists, :organization, foreign_key: true, null: false
  end
end
