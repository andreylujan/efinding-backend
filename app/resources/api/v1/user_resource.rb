# -*- encoding : utf-8 -*-
class Api::V1::UserResource < ApplicationResource
  attributes :rut, :first_name, :last_name, :phone_number,
    :password, :password_confirmation, :email, :role_id,
    :image, :role_name, :full_name, :address

  has_one :role

  def role_id
    @model.role_id.to_s
  end

  def custom_links(options)
    { self: nil }
  end

  def role_name
    @model.organization.name
  end

  def self.find(filters, options = {})
    context = options[:context]
    return context[:current_user]
  end


  def fetchable_fields
    super - [ :password, :password_confirmation ]
  end
end
