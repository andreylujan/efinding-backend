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

class Api::V1::TableColumnResource < ApplicationResource

  attributes :field_name, :column_name, :data_type, :position, :relationship_name,
  	:collection_name

  filters :collection_name
  
  def custom_links(options)
    {self: nil}
  end

  def self.records(options = {})
    context = options[:context]
    user = context[:current_user]
    if user.present?
    	user.organization.table_columns
    else
    	[]
    end
  end

end
