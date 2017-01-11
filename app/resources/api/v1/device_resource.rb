# -*- encoding : utf-8 -*-
class Api::V1::DeviceResource < ApplicationResource
  attributes :os_name, :manufacturer, :model, :os_type, :name, :processor_count,
    :version, :architecture, :uuid, :locale, :registration_id, :device_token

  before_create :set_user

  def set_user(device = @model, context = @context)
    user = context[:current_user]
    device.user = user
  end
end
