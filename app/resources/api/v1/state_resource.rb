# -*- encoding : utf-8 -*-
class Api::V1::StateResource < ApplicationResource
	attributes :name, :color
	has_many :previous_states
	has_many :next_states
	has_many :sections
	has_many :outgoing_transitions
	add_foreign_keys :report_type_id
end
