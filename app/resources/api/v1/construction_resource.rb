# -*- encoding : utf-8 -*-
class Api::V1::ConstructionResource < ApplicationResource
	attributes :name, :company_id, :contractors, :code, :construction_personnel_attributes
	has_one :company
    add_foreign_keys :company_id, :administrator_id, :expert_id

    has_one :administrator 
    has_one :expert
    has_many :construction_personnel
    has_many :contractors
    
    filter :company_id

    def contractors
        @model.contractors.order("name ASC").map { |u| { name: u.name, rut: u.rut, id: u.id } }
    end

    def name
        "#{@model.code} - #{@model.name}"
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

  def fetchable_fields
    super - [ :construction_personnel_attributes ]
  end
end
