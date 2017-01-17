# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: sections
#
#  id              :integer          not null, primary key
#  position        :integer
#  name            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  section_type_id :integer          not null
#  report_type_id  :integer
#
# Indexes
#
#  index_sections_on_report_type_id   (report_type_id)
#  index_sections_on_section_type_id  (section_type_id)
#
# Foreign Keys
#
#  fk_rails_79ab8015ac  (section_type_id => section_types.id)
#  fk_rails_8f2fbe50f3  (report_type_id => report_types.id)
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
