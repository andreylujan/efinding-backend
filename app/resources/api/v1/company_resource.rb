# -*- encoding : utf-8 -*-
class Api::V1::CompanyResource < ApplicationResource
  attributes :name, :company_name
  has_one :organization
  def company_name
    @model.name
  end
  before_save do
    @model.organization = context[:current_user].organization if @model.new_record?
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    companies = Company.where(organization_id: current_user.organization_id)
    if current_user.role.supervisor?
    	companies = companies.joins(:constructions)
    		.where(constructions: { supervisor_id: current_user.id })
    elsif current_user.role.expert?
    	companies = companies.joins(:constructions)
    		.where(constructions: { expert_id: current_user.id })
    end
    companies.distinct
  end

end
