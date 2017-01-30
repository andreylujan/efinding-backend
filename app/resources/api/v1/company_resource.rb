class Api::V1::CompanyResource < ApplicationResource
  attributes :name, :company_name
  has_one :organization
  def company_name
  	@model.name
  end
  before_save do
    @model.organization = context[:current_user].organization if @model.new_record?
  end
end
