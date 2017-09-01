# -*- encoding : utf-8 -*-
class Pitagora::AccidentRatesDashboard
  include ActiveModel::Model
  attr_accessor :id, :tasas_accidentabilidad, 
  	:meta_accidentabilidad, :meta_siniestralidad,
  	:indices_de_frecuencia, :indices_de_gravedad,
  	:tasa_acumulada_accidentabilidad,
  	:tasa_acumulada_siniestralidad
end
