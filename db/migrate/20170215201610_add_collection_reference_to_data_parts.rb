class AddCollectionReferenceToDataParts < ActiveRecord::Migration[5.0]
  def change
    add_reference :data_parts, :collection, foreign_key: true
  end
end
