class Api::V1::ConstructionResource < JSONAPI::Resource
	attributes :name
	has_one :company
end
