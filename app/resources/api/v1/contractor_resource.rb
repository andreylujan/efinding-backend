# -*- encoding : utf-8 -*-
class Api::V1::ContractorResource < JSONAPI::Resource
  attributes :name, :rut

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    Contractor.where(organization_id: current_user.organization_id)
  end
end
