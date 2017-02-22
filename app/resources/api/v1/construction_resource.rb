# -*- encoding : utf-8 -*-
class Api::V1::ConstructionResource < ApplicationResource
	attributes :name, :company_id, :contractors
	has_one :company
    add_foreign_keys :company_id
    has_one :administrator    
    def contractors
        @model.contractors.order("name ASC").map { |u| { name: u.name, rut: u.rut, id: u.id } }
    end

    filter :company_id
    
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
