# -*- encoding : utf-8 -*-
class Api::V1::OrganizationResource < ApplicationResource
  attributes :name, :logo, :default_admin_path
  has_many :roles
  has_many :report_types
  has_many :table_columns
  has_many :collections
  has_many :users
  has_one :checklist

  def custom_links(options)
    { self: nil }
  end

  def fetchable_fields
    super
  end
end
