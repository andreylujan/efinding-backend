# -*- encoding : utf-8 -*-
class Api::V1::SectionResource < ApplicationResource

  attributes :name, :position, :config
  has_many :data_parts, always_include_linkage_data: false
  
  
  def custom_links(options)
    { self: nil }
  end

  def fetchable_fields
    super
  end
end
