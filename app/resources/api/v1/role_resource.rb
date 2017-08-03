# -*- encoding : utf-8 -*-
class Api::V1::RoleResource < ApplicationResource
  attributes :name, :role_type, :can_view_all
  has_one :organization
  def fetchable_fields
    super
  end
  def custom_links(options)
    { self: nil }
  end
end
