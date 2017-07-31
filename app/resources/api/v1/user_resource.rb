# -*- encoding : utf-8 -*-
class Api::V1::UserResource < ApplicationResource
  attributes :rut, :first_name, :last_name, :phone_number,
    :password, :password_confirmation, :email,
    :image, :role_name, :full_name, :address,
    :role_type, :is_superuser, :store_id

  add_foreign_keys :role_id

  has_one :role

  def custom_links(options)
    { self: nil }
  end

  def self.find(filters, options = {})
    context = options[:context]
    return context[:current_user]
  end

  before_save do
    if context[:role_id].present?
      @model.role_id = context[:role_id]
    end
  end


  def fetchable_fields
    super - [ :password, :password_confirmation ]
  end
end
