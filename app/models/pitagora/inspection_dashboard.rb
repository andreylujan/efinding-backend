# -*- encoding : utf-8 -*-
class Pitagora::InspectionDashboard
  include ActiveModel::Model
  attr_accessor :id, :reportes_por_grupo, :cumplimiento_hallazgos,
  :porcentaje_cumplimiento, :indice_de_hallazgos,
  :causas_directas, :causas_basicas
end
