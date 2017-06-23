# -*- encoding : utf-8 -*-
class Api::V1::LocationResource < ApplicationResource
  attributes :lonlat, :accuracy, :provider, :timestamp, :address, :region, :commune,
  	:reference, :altitude

  def fetchable_fields
    super
  end
end
