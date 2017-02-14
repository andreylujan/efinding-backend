# -*- encoding : utf-8 -*-
class Api::V1::DashboardResource < ApplicationResource
	attributes :groupos_actividad,
	:grados_riesgo,
	:groupos_actividad_vs_riesgo, 
	:report_fulfillment,
	:report_ratios,
	:report_locations
end
