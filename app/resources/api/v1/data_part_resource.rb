# -*- encoding : utf-8 -*-
class Api::V1::DataPartResource < ApplicationResource
	attributes :name, :icon, :required, :config, 
		:data_part_type, :position

	add_foreign_keys :data_part_id, :section_id

	def data_part_type
		@model.type
	end

	def section_id
		if @model.section_id
			@model.section_id.to_s
		end
	end

	def data_part_id
		if @model.data_part_id
			@model.data_part_id.to_s
		end
	end

	def self.records(options = {})
    	context = options[:context]
    	DataPart.joins(section: { report_type: :organization}).where(organizations: { id: context[:current_user].organization.id })
    	
  	end

	def custom_links(options)
    { self: nil }
  	end

end
