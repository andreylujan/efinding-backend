# -*- encoding : utf-8 -*-
class Api::V1::ContractorResource < JSONAPI::Resource
  attributes :name, :rut

  before_save do
    @model.organization = context[:current_user].organization if @model.new_record?
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    contractors = Contractor.where(organization_id: current_user.organization_id)
    if not options.has_key? :sort_criteria or options[:sort_criteria].blank?
      contractors = contractors.order("contractors.name ASC")
    end
  end
end
