# -*- encoding : utf-8 -*-
class Api::V1::RoleResource < ApplicationResource
  attributes :name
  has_one :organization
  add_foreign_keys :organization_id
  
  def fetchable_fields
    super
  end
  def custom_links(options)
    { self: nil }
  end
end
