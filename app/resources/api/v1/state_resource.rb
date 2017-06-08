class Api::V1::StateResource < JSONAPI::Resource
	attributes :name
	has_many :previous_states
	has_many :next_states
end
