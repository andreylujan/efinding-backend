# -*- encoding : utf-8 -*-
class Api::V1::InvitationResource < ApplicationResource
  attributes :email, :accepted, :first_name, :last_name
  add_foreign_keys :role_id

 
  def fetchable_fields
    super
  end
end
