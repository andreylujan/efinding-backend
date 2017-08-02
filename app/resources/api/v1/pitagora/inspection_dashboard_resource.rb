# -*- encoding : utf-8 -*-
class Api::V1::Pitagora::InspectionDashboardResource < ApplicationResource
  attributes :reportes_por_grupo, :cumplimiento_hallazgos,
  	:porcentaje_cumplimiento, :indice_de_hallazgos,
  	:causas_directas, :causas_basicas
end
