# -*- encoding : utf-8 -*-
class Api::V1::OrganizationResource < ApplicationResource
  attributes :name, :admin_url, :has_new_button, :logo
  has_many :roles
  has_many :report_types
  has_many :report_columns
  has_many :data_parts
  has_one :default_role
  has_many :activity_types
  has_many :organization_data
    
  def custom_links(options)
    { self: nil }
  end

  def fetchable_fields
    super
  end
end
