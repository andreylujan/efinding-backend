# -*- encoding : utf-8 -*-
class Api::V1::OrganizationDatumResource < JSONAPI::Resource
	attributes :path_suffix, :collection_name, :url
	def url
		"#{ENV['BASE_API_URL']}/#{@model.path_suffix}"
	end
end
