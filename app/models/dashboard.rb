# -*- encoding : utf-8 -*-
class Dashboard
  include ActiveModel::Model
  attr_accessor :id,
  	:groupos_actividad_vs_riesgo, 
	:report_fulfillment,
	:report_ratios,
	:report_locations,
	:grados_riesgo,
	:groupos_actividad
end
