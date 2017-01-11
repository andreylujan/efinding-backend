# -*- encoding : utf-8 -*-
class Api::V1::CheckoutResource < ApplicationResource
  attributes :arrival_time, :exit_time, :data,
		:arrival_lonlat, :exit_lonlat

	
end
