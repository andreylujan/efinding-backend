# -*- encoding : utf-8 -*-
class Api::V1::PersonnelTypeResource < JSONAPI::Resource
  attributes :name

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    PersonnelType.where(organization_id: current_user.organization_id)
  end
end
