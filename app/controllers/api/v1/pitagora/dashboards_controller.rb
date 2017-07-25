# -*- encoding : utf-8 -*-
class Api::V1::Pitagora::DashboardsController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!

  def reports_by_group
    activity_groups = []

    num_total_reports = filtered_reports.count
    reportes_por_grupo = filtered_reports
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

    {
      grupos_actividad: categories,
      num_total_reports: num_total_reports,
      grados_riesgo: riesgos
    }
  end

  def risks
    Collection.find(28).collection_items.map do |item|
      item.name
    end
  end

  def reports_by_month

  end

  def porcentaje_parcial(reports)
    num_total_reports = reports.count.to_f
    if num_total_reports == 0
      '0%'
    else
      percentage = (reports.where("reports.state != ?", "unchecked").count.to_f)/num_total_reports
      (100 * percentage.round(2)).to_i.to_s + '%'
    end
  end
  
  def porcentaje_cumplimiento
    {
      global: porcentaje_parcial(filtered_reports),
      interno: porcentaje_parcial(filtered_internal),
      contratistas: porcentaje_parcial(filtered_other_contractors)
    }
  end

  def filtered_internal
    filtered_reports
      .where("dynamic_attributes->'52'->>'id' = ?", "777")
  end

  def filtered_other_contractors
    filtered_reports
      .where("dynamic_attributes->'52'->>'id' != ?", "777")
  end

  def filtered_reports
    Report.joins(creator: :role).where(roles: { organization_id: 5 })
  end

  def cumplimiento_hallazgos
    reportes_por_riesgo = filtered_reports
    .group("dynamic_attributes->'52'->>'text'")
    .where("reports.state != ?", "unchecked")
    .select("count(*) as num_reports, dynamic_attributes->'52'->>'text' as risk")

    subgroup = {}
    risks.each do |ag|
      subgroup[ag] = 0
    end
    reportes_por_riesgo.each do |group|
      subgroup[group.risk] = group.num_reports
    end
    subgroup.map do |key, value|
      {
        name: key,
        y: value
      }
    end
  end

  def inspections
    dashboard_info = {
      id: SecureRandom.uuid,
      reportes_por_grupo: reports_by_group,
      cumplimiento_hallazgos: cumplimiento_hallazgos,
      porcentaje_cumplimiento: porcentaje_cumplimiento,
      indices_por_mes: reports_by_month
    }
    dashboard = ::Pitagora::InspectionDashboard.new dashboard_info

    render json: JSONAPI::ResourceSerializer.new(Api::V1::Pitagora::InspectionDashboardResource)
    .serialize_to_hash(Api::V1::Pitagora::InspectionDashboardResource.new(dashboard, nil))
  end

end
