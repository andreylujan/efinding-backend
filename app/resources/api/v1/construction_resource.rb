class Api::V1::ConstructionResource < ApplicationResource
	attributes :name, :company_id
	has_one :company

    def company_id
        @model.company_id.to_s
    end

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
