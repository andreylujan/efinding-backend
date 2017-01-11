# -*- encoding : utf-8 -*-
class Api::V1::SectionResource < ApplicationResource

  attributes :name, :section_type_id, :position
  has_many :data_parts, always_include_linkage_data: false
  has_one :section_type
  
  def section_type_id
  	@model.section_type_id.to_s
  end
  
  def custom_links(options)
    { self: nil }
  end

  def fetchable_fields
    super
  end
end
