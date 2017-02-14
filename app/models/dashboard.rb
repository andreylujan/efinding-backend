# -*- encoding : utf-8 -*-
class Dashboard
  include ActiveModel::Model
  attr_accessor :id,
  	:activity_groups, 
	:report_fulfillment,
	:report_ratios,
	:report_locations
end
