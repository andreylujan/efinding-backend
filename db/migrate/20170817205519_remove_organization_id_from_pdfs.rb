class RemoveOrganizationIdFromPdfs < ActiveRecord::Migration[5.0]
  def change
    remove_column :pdfs, :organization_id, :integer
  end
end
