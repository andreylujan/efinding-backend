# -*- encoding : utf-8 -*-
class Api::V1::CommuneResource < ApplicationResource
    
  attributes :name
  add_foreign_keys :region_id

  def fetchable_fields
    super
  end
end
