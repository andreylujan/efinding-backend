# -*- encoding : utf-8 -*-
class Api::V1::InspectionResource < JSONAPI::Resource
	attributes :created_at, :resolved_at
	has_one :construction	
end
