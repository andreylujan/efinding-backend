class Api::V1::Pitagora::InspectionDashboardResource < ApplicationResource
  attributes :reportes_por_grupo, :cumplimiento_hallazgos,
  	:porcentaje_cumplimiento, :indices_por_mes
end
