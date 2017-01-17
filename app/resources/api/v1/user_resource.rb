# -*- encoding : utf-8 -*-
class Api::V1::UserResource < ApplicationResource
  attributes :rut, :first_name, :last_name, :phone_number,
    :password, :password_confirmation, :email, :role_id,
    :image, :role_name, :full_name, :address

  has_many :roles

  def custom_links(options)
    { self: nil }
  end

  def self.find(filters, options = {})
    context = options[:context]
    return context[:current_user]
  end


  def fetchable_fields
    super - [ :password, :password_confirmation ]
  end
end
