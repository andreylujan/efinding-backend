# -*- encoding : utf-8 -*-
class Api::V1::DashboardResource < ApplicationResource
	attributes :report_counts, 
	:reports_by_month,
	:last_month_reports_by_user,
	:current_month_reports_by_user
end
