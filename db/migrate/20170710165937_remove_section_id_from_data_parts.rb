# -*- encoding : utf-8 -*-
class RemoveSectionIdFromDataParts < ActiveRecord::Migration[5.0]
  def change
  	DataPart.all.each do |data_part|
  		if data_part.section.present?
	  		SectionDataPart.create! data_part_id: data_part.id,
	  			editable: true,
	  			position: data_part.position,
	  			section_id: data_part.section_id
	  	end
  	end
    remove_column :data_parts, :section_id, :integer
  end
end
