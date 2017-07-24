# -*- encoding : utf-8 -*-
class Api::V1::InvitationResource < ApplicationResource
  attributes :email, :accepted, :first_name, :last_name,
  	:is_superuser
  add_foreign_keys :role_id
  has_one :role
 
  def fetchable_fields
    super
  end
end
