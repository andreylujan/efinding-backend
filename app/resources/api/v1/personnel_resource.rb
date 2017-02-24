class Api::V1::PersonnelResource < JSONAPI::Resource
  attributes :name, :rut

  before_save do
    @model.organization_id = context[:current_user].organization_id if @model.new_record?
  end
end
