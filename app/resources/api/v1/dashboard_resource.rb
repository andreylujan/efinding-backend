# -*- encoding : utf-8 -*-
class Api::V1::DashboardResource < ApplicationResource
	attributes :activity_groups, 
	:report_fulfillment,
	:report_ratios,
	:report_locations
end
