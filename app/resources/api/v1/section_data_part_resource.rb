# -*- encoding : utf-8 -*-
class Api::V1::SectionDataPartResource < ApplicationResource
	attributes :editable, :position
	has_one :data_part
	add_foreign_keys :section_id, :data_part_id
end
