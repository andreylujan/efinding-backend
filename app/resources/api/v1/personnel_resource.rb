# -*- encoding : utf-8 -*-
class Api::V1::PersonnelResource < JSONAPI::Resource

  attributes :name, :rut, :email
  has_many :personnel_types
  has_many :constructions

  before_save do
    @model.organization_id = context[:current_user].organization_id if @model.new_record?
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    Personnel.where(organization_id: current_user.organization_id)
  end
end
