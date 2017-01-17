# -*- encoding : utf-8 -*-
class Api::V1::DataPartResource < ApplicationResource
	attributes :name, :icon, :required, :config, :section_id,
		:data_part_id, :data_part_type, :position

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
    	context[:current_user].organization.data_parts
  	end

	def custom_links(options)
    { self: nil }
  	end

end