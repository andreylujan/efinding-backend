# -*- encoding : utf-8 -*-
class Api::V1::DataPartResource < ApplicationResource
	attributes :name, :icon, :required, :config, 
		:data_part_type, :position

	add_foreign_keys :section_id

	def data_part_type
		@model.type
	end

	def self.records(options = {})
    	context = options[:context]
    	DataPart.joins(section: { report_type: :organization}).where(organizations: { id: context[:current_user].organization.id })
    	
  	end

	def custom_links(options)
    { self: nil }
  	end

end
