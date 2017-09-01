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
    .order("dynamic_attributes->'69'->>'text' ASC")
    .map do |group|
      {
        count_all: group.count_all,
        activity_group: group.activity_group,
        risk: group.risk
      }
    end
    .group_by do |group|
      group[:activity_group]
    end


    reportes_por_grupo = reportes_por_grupo.map do |activity_group, reports|
      activity_groups << activity_group
      subgroup = {}
      risks.each do |ag|
        subgroup[ag] = 0
      end
      reports.group_by { |r| r[:risk] }
      .each do |risk, subreports|
        subgroup[risk] = subreports.inject(0) { |sum, x| sum + x[:count_all] }
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
                                        "CASE WHEN(sum(worker_average) > 0) THEN count(reports.id)/sum(worker_average) ELSE 0 END as index")
      .where("accident_rates.rate_period = date(?)", month)
      .where("reports.created_at >= ? AND reports.created_at <= ?",
             month,
             month.end_of_month)
      .map do |group|
        {
          name: group.construction_name,
          index: group.index.round(2)
        }
      end

      all_indexes = filtered_reports.joins(inspection: { construction: :accident_rates })
      .select("CASE WHEN(sum(worker_average) > 0) THEN count(reports.id)/sum(worker_average) ELSE 0 END as index")
      .where("accident_rates.rate_period = date(?)", month)
      .where("reports.created_at >= ? AND reports.created_at <= ?",
             month,
             month.end_of_month)
      .map do |group|
        {
          index: group.index.round(2)
        }
      end
      data << {
        mes: I18n.l(month, format: "%B"),
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
      percentage = (reports.where("reports.state = ?", "resolved").count.to_f)/num_total_reports
      (100 * percentage.round(2)).to_i.to_s + '%'
    end
  end

  def resolved_reports
    filtered_reports.where("reports.state = ?", "resolved")
  end
  
  def porcentaje_cumplimiento
    resolved = resolved_reports
    internal = resolved.where("dynamic_attributes->'68'->>'id' = ?", "777")
    other = resolved.where("dynamic_attributes->'68'->>'id' != ?", "777")
    num_total = internal.count + other.count
    interno = 0
    contratistas = 0
    if num_total > 0
      interno = internal.count.to_f/num_total.to_f
    end
    interno = (interno.round(2)*100).to_i
    contratistas = 100 - interno

    {
      global: porcentaje_parcial(filtered_reports),
      interno: interno.to_s + "%",
      contratistas: contratistas.to_s + "%"
    }
  end

  def filtered_internal
    filtered_reports
    .where("dynamic_attributes->'68'->>'id' = ?", "777")
  end

  def filtered_other_contractors
    filtered_reports
    .where("dynamic_attributes->'68'->>'id' != ?", "777")
  end

  def filtered_reports
    reports = Api::V1::ReportResource.records({
                                                context: {
                                                  current_user: current_user
                                                },
                                                order: false,
                                                dashboard: true
    })
    params.permit!
    params_hash = params.to_h
    params_hash[:filter] ||= {}
    filters = Api::V1::ReportResource.verify_filters(params_hash[:filter])

    reports = Api::V1::ReportResource.apply_filters(reports,
                                                    filters)
  end

  def cumplimiento_hallazgos
    reportes_por_riesgo = filtered_reports
    .group("reports.state")
    .select("count(*) as num_reports, reports.state as state")
    states_hash = {
      "resolved" => "Resuelto",
      "pending" => "Pendiente",
      "unchecked" => "En proceso"
    }
    subgroup = {}
    states_hash.each do |ag, val|
      subgroup[val] = 0
    end
    reportes_por_riesgo.each do |group|
      subgroup[states_hash[group.state]] = group.num_reports
    end
    subgroup.map do |key, value|
      {
        name: key,
        y: value
      }
    end
  end


  def global_casualty_rates
    filtered_accident_rates.group("rate_period")
    .select("rate_period, avg(accident_rate) as accident_rate")
    .order("rate_period ASC")
    .map do |group|
      {
        mes: I18n.l(group.rate_period, format: "%B-%Y"),
        tasa_accidentabilidad: group.accident_rate
      }
    end
  end

  def filtered_accident_rates
    accident_rates = Api::V1::AccidentRateResource.records({
                                                             context: {
                                                             current_user: current_user                                                        },
    })
    params.permit!
    params_hash = params.to_h
    params_hash[:filter] ||= {}
    filters = Api::V1::AccidentRateResource.verify_filters(params_hash[:filter])

    accident_rates = Api::V1::AccidentRateResource.apply_filters(accident_rates,
                                                                 filters)
  end

  def accident_rates

    rates = filtered_accident_rates.group("rate_period")
    .select("rate_period, avg(accident_rate) as accident_rate, avg(casualty_rate) as casualty_rate")
    .order("rate_period ASC")
    .map do |group|
      {
        mes: I18n.l(group.rate_period, format: "%B-%Y"),
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

    indices_de_frecuencia = {}
    indices_de_gravedad = {}
    tasa_acumulada_accidentabilidad = nil
    tasa_acumulada_siniestralidad = nil


    if params.dig(:filter, :construction_id).present?

      rate_period = Date.today.beginning_of_month
      if period_filter = params.dig(:filter, :period)
        date_str = period_filter.split("/")
        year = date_str[1].to_i
        month = date_str[0].to_i
        rate_period = Date.new(year, month)
      end

      semester_rates = AccidentRate
        .where(construction_id: params.dig(:filter, :construction_id))
        .where("rate_period >= ? AND rate_period <= ?", rate_period - 6.months, rate_period - 1.month)

      6.times do |i|
        month = rate_period - (6 - i).months
        indices_de_frecuencia[month] =
        {
          mes: I18n.l(month, format: "%B"),
          indice_de_frecuencia: 0.0
        }

        indices_de_gravedad[month] =
        {
          mes: I18n.l(month, format: "%B"),
          indice_de_gravedad: 0.0
        }

      end
      
      month_rate = AccidentRate.find_by_construction_id_and_rate_period(params.dig(:filter, :construction_id), rate_period)
      global_data = MonthlyGlobalData.find_by(organization: current_user.organization, month_date: rate_period)

      if month_rate.present? and global_data.present? and global_data.num_workers > 0
        num_workers = global_data.num_workers
        num_accidents = month_rate.num_accidents
        num_days_lost = month_rate.num_days_lost
        tasa_acumulada_accidentabilidad = (num_accidents.to_f / num_workers.to_f) * 100.0
        tasa_acumulada_siniestralidad = (num_days_lost.to_f / num_workers.to_f) * 100.0
      end

      semester_rates
      .order("rate_period ASC")
      .each do |rate|
        indices_de_frecuencia[rate.rate_period][:indice_de_frecuencia] = rate.frequency_index
      end

      semester_rates
      .order("rate_period ASC")
      .each do |rate|
        indices_de_gravedad[rate.rate_period][:indice_de_gravedad] = rate.gravity_index
      end
    end



    dashboard_info = {
      id: SecureRandom.uuid,
      tasas_accidentabilidad: rates,
      meta_accidentabilidad: [[0, 2], [rates.length - 1, 2]],
      meta_siniestralidad: [[0, 25], [rates.length - 1, 25]],
      indices_de_frecuencia: indices_de_frecuencia.map { |key, value| value},
      indices_de_gravedad: indices_de_gravedad.map { |key, value| value},
      tasa_acumulada_accidentabilidad: tasa_acumulada_accidentabilidad,
      tasa_acumulada_siniestralidad: tasa_acumulada_siniestralidad
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

  def filtered_checklists
    if params[:checklist_id]
      checklist_id = params[:checklist_id]
    else
      checklist_id = current_user.organization.checklist_id
    end
    reports = Api::V1::ChecklistReportResource.records({
                                                         context: {
                                                         current_user: current_user                                                        },
                                                         order: false
    })

    params.permit!
    params_hash = params.to_h
    params_hash[:filter] ||= {}
    filters = Api::V1::ChecklistReportResource.verify_filters(params_hash[:filter])

    reports = Api::V1::ChecklistReportResource.apply_filters(reports,
                                                             filters)
  end

  def fullfillment(checklists)
    num_items = 0
    num_fullfilled = 0
    checklists.each do |checklist|
      checklist.checklist_data.each do |section|
        section["items"].each do |item|
          if item["value"] != 0 and item["value"].present?
            if item["value"] == 1
              num_fullfilled += 1
            end
            num_items += 1
          end
        end
      end
    end
    if num_items > 0
      ((num_fullfilled.to_f/num_items.to_f).round(2)*100).to_i
    else
      0
    end
  end

  def checklists

    cumplimiento_por_periodo = filtered_checklists
    .order("checklist_reports.created_at ASC").group_by do |checklist|
      Date.new(checklist.created_at.year, checklist.created_at.month)
    end.map do |key, group|
      {
        date: key,
        cumplimiento: fullfillment(group).to_s + "%"
      }
    end

    obras_bajo_meta = filtered_checklists
    .group_by do |checklist|
      checklist.construction
    end.map do |key, group|
      {
        obra: key.name,
        cumplimiento: fullfillment(group)
      }
    end
    .sort do |c1, c2|
      c1[:cumplimiento] <=> c2[:cumplimiento]
    end[0...10].map do |cump|
      {
        obra: cump[:obra],
        cumplimiento: cump[:cumplimiento].to_s + "%"
      }
    end

    cumplimiento_por_obra = filtered_checklists
    .joins(:construction)
    .order("constructions.name ASC")
    .group_by do |checklist|
      checklist.construction
    end.map do |key, group|
      {
        obra: key.name,
        cumplimiento: fullfillment(group)
      }
    end.map do |cump|
      {
        obra: cump[:obra],
        cumplimiento: cump[:cumplimiento].to_s + "%"
      }
    end

    dashboard_info = {
      id: SecureRandom.uuid,
      cumplimiento_minimo: "50%",
      cumplimiento_por_periodo: cumplimiento_por_periodo,
      cumplimiento_por_obra: cumplimiento_por_obra,
      obras_bajo_meta: obras_bajo_meta
    }
    dashboard = ::Pitagora::ChecklistDashboard.new dashboard_info

    render json: JSONAPI::ResourceSerializer.new(Api::V1::Pitagora::ChecklistDashboardResource)
    .serialize_to_hash(Api::V1::Pitagora::ChecklistDashboardResource.new(dashboard, nil))
  end


end
