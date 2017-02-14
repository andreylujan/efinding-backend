# -*- encoding : utf-8 -*-
class RemoveOrganizationReferenceFromDataParts < ActiveRecord::Migration[5.0]
  def change
    remove_reference :data_parts, :organization, foreign_key: true
  end
end
