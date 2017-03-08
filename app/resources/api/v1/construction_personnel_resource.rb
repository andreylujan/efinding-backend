# -*- encoding : utf-8 -*-
class Api::V1::ConstructionPersonnelResource < JSONAPI::Resource
	has_one :personnel
	has_one :personnel_type
end
