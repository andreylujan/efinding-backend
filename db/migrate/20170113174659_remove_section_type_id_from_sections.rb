# -*- encoding : utf-8 -*-
class RemoveSectionTypeIdFromSections < ActiveRecord::Migration[5.0]
  def change
    remove_column :sections, :section_type_id, :integer
  end
end
