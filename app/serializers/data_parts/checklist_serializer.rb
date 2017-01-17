# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: data_parts
#
#  id            :integer          not null, primary key
#  subsection_id :integer
#  type          :text             not null
#  name          :text             not null
#  icon          :text
#  required      :boolean          default(TRUE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ancestry      :string
#

class ChecklistSerializer < DataPartSerializer
	has_many :options

	def options
		parts = []
		object.children.each do |part|
			
			arr = part.subtree.arrange_serializable do |parent, children|
				serializer = Object.const_get "#{parent.type}Serializer"
				serializer.new(parent, children: children).as_json
			end
			parts << arr[0]
		end
		parts
	end
	
end
