# -*- encoding : utf-8 -*-
class Api::V1::RegionResource < ApplicationResource
    
  attributes :name, :roman_numeral, :number
  has_many :communes

  def fetchable_fields
    super
  end
end
