class Api::V1::CompanyResource < JSONAPI::Resource
  attributes :name
  before_save do
    @model.organization = context[:current_user].organization if @model.new_record?
  end
end
