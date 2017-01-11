# -*- encoding : utf-8 -*-
class Api::V1::CommuneResource < ApplicationResource
    
  attributes :name, :region_id

  def region_id
  	@model.region_id.to_s
  end

  def fetchable_fields
    super
  end
end
