# -*- encoding : utf-8 -*-
class Api::V1::Pitagora::AccidentRatesDashboardResource < ApplicationResource
  attributes :tasas_accidentabilidad, :meta_accidentabilidad, :meta_siniestralidad,
  :indices_de_frecuencia, :indices_de_gravedad,
  	:tasa_acumulada_accidentabilidad,
  	:tasa_acumulada_siniestralidad
end
