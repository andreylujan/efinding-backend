# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: report_colunms
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  field_name      :text
#  column_name     :text
#  column_type     :integer
#  position        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Api::V1::ReportColumnResource < ApplicationResource

	attributes :field_name, :column_name, :data_type, :position, :relationship_name
	
	def custom_links(options)
    	{self: nil}
  	end

end
