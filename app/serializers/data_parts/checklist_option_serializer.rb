# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  name            :text             not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ChecklistOptionSerializer < DataPartSerializer
	attributes :detail

	def detail
		if object.detail.present?
			SubsectionSerializer.new(object.detail).as_json
		end
	end
end
