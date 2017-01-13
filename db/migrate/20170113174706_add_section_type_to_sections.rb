# -*- encoding : utf-8 -*-
class AddSectionTypeToSections < ActiveRecord::Migration[5.0]
  def change
    add_column :sections, :section_type, :integer
  end
end
