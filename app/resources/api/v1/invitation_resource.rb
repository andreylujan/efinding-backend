# -*- encoding : utf-8 -*-
class Api::V1::InvitationResource < ApplicationResource
  attributes :email, :role_id, :accepted, :first_name, :last_name

  def role_id
  	@model.role_id.to_s
  end

  def fetchable_fields
    super
  end
end
