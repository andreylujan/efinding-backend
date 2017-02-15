# -*- encoding : utf-8 -*-
class AddOrganizationReferenceToCollections < ActiveRecord::Migration[5.0]
  def change
    add_reference :collections, :organization, foreign_key: true
  end
end
