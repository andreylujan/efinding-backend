# -*- encoding : utf-8 -*-
class Pitagora::ChecklistDashboard
  include ActiveModel::Model
  attr_accessor :id, :cumplimiento_por_periodo, :cumplimiento_por_obra, :cumplimiento_minimo
end
