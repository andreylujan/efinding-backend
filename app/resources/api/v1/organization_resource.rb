# -*- encoding : utf-8 -*-
class Api::V1::OrganizationResource < ApplicationResource
  attributes :name, :logo
  has_many :roles
  has_many :report_types
  has_many :report_columns
  has_many :data_parts
    
  def custom_links(options)
    { self: nil }
  end

  def fetchable_fields
    super
  end
end