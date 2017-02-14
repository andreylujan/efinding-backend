# -*- encoding : utf-8 -*-
class Api::V1::DashboardResource < ApplicationResource
	attributes :grupos_actividad,
	:grados_riesgo,
	:grupos_actividad_vs_riesgo, 
	:report_fulfillment,
	:report_ratios,
	:report_locations
end
