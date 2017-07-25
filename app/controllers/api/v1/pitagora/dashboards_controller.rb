# -*- encoding : utf-8 -*-
class Api::V1::Pitagora::DashboardsController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!

  def causas_directas
    # 55
    reports = filtered_reports
    .group("dynamic_attributes->'55'->>'text'")
    .select("count(reports.id) as num_reports, dynamic_attributes->'55'->>'text' as causa_directa")
    .order("count(reports.id) DESC")
    .map do |group|
      {
        causa_directa: group.causa_directa,
        num_reports: group.num_reports
      }
    end
  end

  def causas_basicas
    # 58
    reports = filtered_reports
    .group("dynamic_attributes->'58'->>'text'")
    .select("count(reports.id) as num_reports, dynamic_attributes->'58'->>'text' as causas_basica")
    .order("count(reports.id) DESC")
    .map do |group|
      {
        causas_basica: group.causas_basica,
        num_reports: group.num_reports
      }
    end
  end

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
    data = []
    months = [
      DateTime.now.beginning_of_month - 3.months,
      DateTime.now.beginning_of_month - 2.months,
      DateTime.now.beginning_of_month - 1.month
    ]
    months.each do |month|
      indexes_by_construction = filtered_reports.joins(inspection: { construction: :accident_rates })
      .group("constructions.id").select("constructions.name as construction_name, " +
                                        "CASE WHEN(count(worker_average) > 0) THEN count(reports.id)/count(worker_average) ELSE 0 END as index")
      .where("accident_rates.rate_period = date(?)", month)
      .where("reports.created_at >= ? AND reports.created_at <= ?",
             month,
             month.end_of_month)
      .map do |group|
        {
          name: group.construction_name,
          index: group.index
        }
      end

      all_indexes = filtered_reports.joins(inspection: { construction: :accident_rates })
      .select("CASE WHEN(count(worker_average) > 0) THEN count(reports.id)/count(worker_average) ELSE 0 END as index")
      .where("accident_rates.rate_period = date(?)", month)
      .where("reports.created_at >= ? AND reports.created_at <= ?",
             month,
             month.end_of_month)
      .map do |group|
        {
          index: group.index
        }
      end
      data << {
        mes: month.strftime("%B"),
        indices_por_obra: indexes_by_construction,
        indices_totales: all_indexes
      }
    end
    data

    # asdasd = Construction.joins("LEFT OUTER JOIN inspections ON inspections.construction_id =
    #   constructions.id")
    #   .joins("LEFT OUTER join reports ON reports.inspection_id = inspections.id")
    #   .joins("LEFT OUTER JOIN accident_rates ON accident_rates.construction_id = constructions.id")
    #   .distinct
    #   .select("count(reports.id)/count(worker_average) as index")
    #   byebug

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

  def global_accident_rates
    rates = filtered_accident_rates.group("rate_period")
      .select("rate_period, avg(accident_rate) as accident_rate, avg(casualty_rate) as casualty_rate")
      .order("rate_period ASC")
      .map do |group|
        {
          mes: group.rate_period.strftime("%B-%Y"),
          tasa_accidentabilidad: group.accident_rate,
          tasa_siniestralidad: group.casualty_rate
        }
      end
    rates.each_with_index do |rate, idx|
      if idx == 0
        rate[:tasa_accidentabilidad_acumulada] = rate[:tasa_accidentabilidad]
        rate[:tasa_siniestralidad_acumulada] = rate[:tasa_siniestralidad]
      else
        rate[:tasa_accidentabilidad_acumulada] = 
          rates[idx-1][:tasa_accidentabilidad_acumulada]*(rate[:tasa_accidentabilidad] + 1.0)
        rate[:tasa_siniestralidad_acumulada] = 
          rates[idx-1][:tasa_siniestralidad_acumulada]*(rate[:tasa_siniestralidad] + 1.0)
      end
    end
    rates
  end

  def global_casualty_rates
    filtered_accident_rates.group("rate_period")
      .select("rate_period, avg(accident_rate) as accident_rate")
      .order("rate_period ASC")
      .map do |group|
        {
          mes: group.rate_period.strftime("%B-%Y"),
          tasa_accidentabilidad: group.accident_rate
        }
      end
  end

  def filtered_accident_rates
    AccidentRate.where(organization: current_user.organization)
  end

  def accident_rates
    dashboard_info = {
      id: SecureRandom.uuid,
      tasa_accidentabilidad: global_accident_rates
    }
    dashboard = ::Pitagora::AccidentRatesDashboard.new dashboard_info

    render json: JSONAPI::ResourceSerializer.new(Api::V1::Pitagora::AccidentRatesDashboardResource)
    .serialize_to_hash(Api::V1::Pitagora::AccidentRatesDashboardResource.new(dashboard, nil))
  end

  def inspections
    dashboard_info = {
      id: SecureRandom.uuid,
      reportes_por_grupo: reports_by_group,
      cumplimiento_hallazgos: cumplimiento_hallazgos,
      porcentaje_cumplimiento: porcentaje_cumplimiento,
      indice_de_hallazgos: reports_by_month,
      causas_directas: causas_directas,
      causas_basicas: causas_basicas
    }
    dashboard = ::Pitagora::InspectionDashboard.new dashboard_info

    render json: JSONAPI::ResourceSerializer.new(Api::V1::Pitagora::InspectionDashboardResource)
    .serialize_to_hash(Api::V1::Pitagora::InspectionDashboardResource.new(dashboard, nil))
  end

end
