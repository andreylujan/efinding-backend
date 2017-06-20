# -*- encoding : utf-8 -*-
class Api::V1::StateResource < JSONAPI::Resource
	attributes :name, :color
	has_many :previous_states
	has_many :next_states
	has_many :sections
	has_many :outgoing_transitions
end
