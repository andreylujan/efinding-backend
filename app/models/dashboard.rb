# -*- encoding : utf-8 -*-
class Dashboard
  include ActiveModel::Model
  attr_accessor :id,
  	:report_counts, 
	:reports_by_month,
	:last_month_reports_by_user,
	:current_month_reports_by_user
end
