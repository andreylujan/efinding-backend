# -*- encoding : utf-8 -*-
class AddOrganizationReferenceToTableColumns < ActiveRecord::Migration[5.0]
  def change
    add_reference :table_columns, :organization, foreign_key: true
  end
end
