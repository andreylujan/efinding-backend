# -*- encoding : utf-8 -*-
class Api::V1::Pitagora::DashboardsController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!

  def inspections

    risks = Collection.find(28).collection_items.map do |item|
      item.name
    end
    activity_groups = []
    reportes_por_grupo = Report.joins(creator: :role).where(roles: { organization_id: 5 })
      .group("dynamic_attributes->'69'->>'text', dynamic_attributes->'52'->>'text'")
      .select("count(*) as count_all, dynamic_attributes->'69'->>'text' as activity_group, dynamic_attributes->'52'->>'text' as risk")
    .group_by do |group|
      group.activity_group
    end.map do |activity_group, reports|
      activity_groups << activity_group
      subgroup = {}
      risks.each do |ag|
        subgroup[ag] = 0
      end
      reports.group_by { |r| r.risk }
      .each do |risk, subreports|
        subgroup[risk] = reports.length
      end
      {
        grupo_actividad: activity_group,
        por_riesgo: subgroup.map do |risk, risk_val|
          {
            name: risk,
            num_reports: risk_val
          }
        end
      }
    end
    categories = activity_groups
    riesgos = []
    risks.each do |risk|
      riesgos << {
          name: risk,
          data: []
        }
    end
    reportes_por_grupo.each do |grupo_actividad|
      grupo_actividad[:por_riesgo].each_with_index do |riesgo, idx|
        riesgos[idx][:data] << riesgo[:num_reports]
      end
    end
    dashboard_info = {
      id: SecureRandom.uuid,
      reportes_por_grupo:  {
        grupos_actividad: categories,
        grados_riesgo: riesgos
      }

    }
    dashboard = ::Pitagora::InspectionDashboard.new dashboard_info

    render json: JSONAPI::ResourceSerializer.new(Api::V1::Pitagora::InspectionDashboardResource)
    .serialize_to_hash(Api::V1::Pitagora::InspectionDashboardResource.new(dashboard, nil))
  end

end
