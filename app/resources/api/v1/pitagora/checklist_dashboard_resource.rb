# -*- encoding : utf-8 -*-
class Api::V1::Pitagora::ChecklistDashboardResource < ApplicationResource
	attributes :cumplimiento_por_periodo, :cumplimiento_por_obra, :obras_bajo_meta, :cumplimiento_minimo
end
