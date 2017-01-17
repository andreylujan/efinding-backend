# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: sections
#
#  id             :integer          not null, primary key
#  position       :integer
#  name           :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  report_type_id :integer
#  section_type   :integer
#

class SectionSerializer < ActiveModel::Serializer
	attributes :id, :position, :name, :subsections, :section_type

	def section_type
		{
			id: object.section_type.id,
			name: object.section_type.name
		}
	end

	def subsections
		sub = []
		object.subsections.each do |s|
			sub << SubsectionSerializer.new(s).as_json
		end
		sub
	end
end
