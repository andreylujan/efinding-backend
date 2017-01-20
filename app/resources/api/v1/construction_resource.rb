class Api::V1::ConstructionResource < ApplicationResource
	attributes :name
	has_one :company

	def self.records(options = {})
    context = options[:context]
    if context[:company_id]
    	Company.find(context[:company_id]).constructions
    else
    	Construction.joins(company: :organization)
    		.where(organizations: { id: context[:current_user].organization.id })
    end
  end
end
