# -*- encoding : utf-8 -*-
class Api::V1::ChecklistResource < ApplicationResource
  attributes :name, :sections, :formatted_created_at

  before_save do
    @model.organization_id = context[:current_user].organization_id if @model.new_record?
  end
end
