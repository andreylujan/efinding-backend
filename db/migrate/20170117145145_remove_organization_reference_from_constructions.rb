# -*- encoding : utf-8 -*-
class RemoveOrganizationReferenceFromConstructions < ActiveRecord::Migration[5.0]
  def change
    remove_reference :constructions, :organization, foreign_key: true
  end
end
