# -*- encoding : utf-8 -*-
class Api::V1::DashboardController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!, except: [ :idd_public ]

  def filter_by_organization(reports = nil)
    if reports.nil?
      Report.joins(creator: :role)
      .where(roles: { organization_id: current_user.organization_id })
    else
      reports.joins(creator: :role)
      .where(roles: { organization_id: current_user.organization_id })
    end
  end

  def generic
    yearly_reports = filter_by_organization(Report
                                            .includes(:assigned_user, :creator)
                                            .where("reports.created_at >= ? AND reports.created_at < ?",
                                                   DateTime.now.beginning_of_year, DateTime.now.end_of_year)
                                            .order('reports.created_at ASC'))
    filtered_reports = yearly_reports
    reports_by_month = filtered_reports.group_by(&:month_criteria).map do |month|

      {
        num_assigned: month[1].count { |r| r.is_assigned? },
        num_executed: month[1].count { |r| r.state_id == 25 },
        month_name: I18n.l(month[0], format: '%B').capitalize

      }
    end

    current_month_user_reports = filtered_reports.where("reports.created_at >= ? AND reports.created_at < ?",
        DateTime.now.beginning_of_month, DateTime.now.end_of_month)
        # .where.not(assigned_user_id: nil)

    current_month_reports_by_user = current_month_user_reports.where(is_assigned: true).group_by(&:assigned_user).map do |info|
      {
        user_name: info[0].name,
        num_assigned_reports: info[1].length,
        num_executed_reports: info[1].count { |r| r.state_id == 25 }
      }
    end.sort! { |a, b| a[:user_name] <=> b[:user_name] }

    last_month_user_reports = filtered_reports.where("reports.created_at >= ? AND reports.created_at < ?",
        DateTime.now.beginning_of_month - 1.month, DateTime.now.end_of_month - 1.month)
        # .where.not(assigned_user_id: nil)

    last_month_reports_by_user = last_month_user_reports.where(is_assigned: true).group_by(&:assigned_user).select { |x| x.present? }.map do |info|
      {
        user_name: info[0].name,
        num_assigned_reports: info[1].length,
        num_executed_reports: info[1].count { |r| r.state_id == 25 }
      }
    end.sort! { |a, b| a[:user_name] <=> b[:user_name] }

    report_counts = {
      num_last_month: last_month_user_reports.count,
      num_current_month: current_month_user_reports.count
    }

    dashboard_info = {
      report_counts: report_counts,
      reports_by_month: reports_by_month,
      last_month_reports_by_user: last_month_reports_by_user,
      current_month_reports_by_user: current_month_reports_by_user
    }

    render json: {
      data: {
        id: SecureRandom.uuid,
        type: "dashboards",
        attributes: dashboard_info
      }
    }
  end


  def intralot
    date = DateTime.now
    if params[:year].present? and params[:month].present?
      year = params.require(:year).to_i
      month = params.require(:month).to_i
      date = DateTime.new(year, month)
    end

    reports = Report.joins(creator: :role)
    .where(roles: { organization_id: current_user.organization_id })
    .where("reports.created_at >= ? AND reports.created_at <= ?",
           date.beginning_of_month,
           date.end_of_month
           )

     reports_by_month = reports.group_by(&:month_criteria).map do |month|
       {
         num_assigned: month[1].count { |r| r.is_assigned? },
         num_executed: month[1].count { |r| r.state_id == 25 },
         month_name: I18n.l(month[0], format: '%B').capitalize
       }
     end

     reports_by_day = reports.where("reports.created_at >= ? AND reports.created_at < ?",
         Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)

     reports_last_fifteen_days = reports.where("reports.created_at >= ? AND reports.created_at < ?",
         DateTime.now.days_ago(-15).beginning_of_day, DateTime.now.end_of_day)

     current_month_user_reports = reports.where("reports.created_at >= ? AND reports.created_at < ?",
         DateTime.now.beginning_of_month, DateTime.now.end_of_month)
         # .where.not(assigned_user_id: nil)

     reports_by_delivery_result = reports.group("dynamic_attributes->'118'->>'value'")
       .select("count(reports.id) AS num_reports, dynamic_attributes->'118'->>'value' AS start_date")
       .order("count(reports.id) DESC")
       .map do |group|
         {
           num_reports: group.num_reports,
           reason: group.state
         }
     end

     reports_by_week = reports.group("reports.created_at")
       .select("count(reports.id) AS num_reports, reports.created_at AS week")
       .order("reports.created_at DESC")
       .map do |group|{
         num_reports: group.num_reports,
         week: week.strftime('%U') + 1
       }
     end

     report_counts = {
       num_reports_by_day: reports_by_day.count,
       num_reports_last_fifteen_days: reports_last_fifteen_days.count,
       num_current_month: current_month_user_reports.count
     }


     render json: {
       data: {
         id: "#{date.month}/#{date.year}",
         type: "dashboards",
         attributes: {
           reports_by_day: reports_by_day,
           reports_last_fifteen_days: reports_last_fifteen_days,
           current_month_user_reports: current_month_user_reports,
           reports_by_delivery_result: reports_by_delivery_result,
           reports_by_week: reports_by_week,
           report_counts: report_counts
         }
       }
     }


  end

  def intralot_
    yearly_reports = filter_by_organization(Report
                                            .includes(:assigned_user, :creator)
                                            .where("reports.created_at >= ? AND reports.created_at < ?",
                                                   DateTime.now.beginning_of_year, DateTime.now.end_of_year)
                                            .order('reports.created_at ASC'))
    filtered_reports = yearly_reports

    reports_by_month = filtered_reports.group_by(&:month_criteria).map do |month|
      {
        num_assigned: month[1].count { |r| r.is_assigned? },
        num_executed: month[1].count { |r| r.state_id == 25 },
        month_name: I18n.l(month[0], format: '%B').capitalize
      }
    end

    reports_by_day = filtered_reports.where("reports.created_at >= ? AND report.created_at < ?",
        Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)

    reports_last_fifteen_days = filtered_reports.where("reports.created_at >= ? AND reports.created_at < ?",
        DateTime.now.days_ago(-15).beginning_of_day, DateTime.now.end_of_day)

    current_month_user_reports = filtered_reports.where("reports.created_at >= ? AND reports.created_at < ?",
        DateTime.now.beginning_of_month, DateTime.now.end_of_month)
        # .where.not(assigned_user_id: nil)

    current_month_reports_by_user = current_month_user_reports.where(is_assigned: true).group_by(&:assigned_user).map do |info|
      {
        user_name: info[0].name,
        num_assigned_reports: info[1].length,
        num_executed_reports: info[1].count { |r| r.state_id == 25 }
      }
    end.sort! { |a, b| a[:user_name] <=> b[:user_name] }

    reports_by_delivery_result = filtered_reports.group("dynamic_attributes->'118'->>'value'")
      .select("count(filtered_reports.id) AS num_reports, dynamic_attributes->'118'->>'value' AS start_date")
      .order("count(reports.id) DESC")
      .map do |group|
        {
          num_reports: group.num_reports,
          reason: group.state
        }
    end

    reports_by_week = filtered_reports.group("report.created_at.strftime('%U')")
      .where("report.created_at IS NOT NULL")
      .order("report.created_at.strftime('%U') + 1 DESC")
      .select("count(filtered_reports.id) AS num_reports, report.created_at.strftime('%U') + 1 AS week")
      .map do |group|{
        num_reports: group.num_reports,
        week: week
      }
    end

    report_counts = {
      num_reports_by_day: reports_by_day.count,
      num_reports_last_fifteen_days: reports_last_fifteen_days.count,
      num_current_month: current_month_user_reports.count
    }
    dashboard_info = {
      report_counts: report_counts,
      reports_by_month: reports_by_month,
      last_month_reports_by_user: last_month_reports_by_user,
      current_month_reports_by_user: current_month_reports_by_user,
      reports_by_delivery_result: reports_by_delivery_result,
      reports_last_fifteen_days: reports_last_fifteen_days,
      reports_by_day: reports_by_day,
      reports_by_week: reports_by_week
    }
    render json: {
        data: {
          id: SecureRandom.uuid,
          type: "dashboards",
          attributes: dashboard_info
        }
      }
  end

  def show_manflas
    reports = Api::V1::ReportResource.records({
                                                context: {
                                                  current_user: current_user,
                                                  dashboard: true
                                                },
                                                order: ""
    })
    # filters = Api::V1::ReportResource.verify_filters(params[:filter])
    # filters = params[:filter] || {}
    # if filters[:start_date].present?
    #   reports = reports.where("reports.created_at >= ?", filters[:start_date])
    # end
    # if filters[:end_date].present?
    #   reports = reports.where("reports.created_at <= ?", filters[:start_date])
    # end
    # if filters[:state_name].present?
    #   reports = reports.where("reports.state = ?", Report.states[filters[:state_name]])
    # end
    # if filters[:area_id].present?
    #   reports = reports.where("dynamic_attributes->>'43' = ?", filters[:area_id])
    # end
    # reports = Api::V1::ReportResource.apply_filters(reports,
    #                                                        filters)
    report_ratios = [
      {
        state: "unchecked",
        num_reports: 0
      },
      {
        state: "resolved",
        num_reports: 0
      }
    ]

    sql_ratios = reports.group("reports.state").select("reports.state, count(reports.id) as num_reports")
    .as_json.map do |json|
      json.delete "id"
      json
    end
    sql_ratios.each do |ratio|
      idx = ratio["state"] == "unchecked" ? 0 : 1
      report_ratios[idx]["num_reports"] = ratio["num_reports"]
    end

    state_names = Report.states.keys
    report_fulfillment = reports.group_by(&:station_id_criteria).map do |station_id, report_group|
      json = {}
      begin
        station = ::Manflas::Station.find(station_id)
        json[:inspection_id] = station.name
        state_names.each do |state_name|
          json["num_" + state_name.to_s] = report_group.count do |report|
            report.state == state_name.to_s
          end
        end
        json
      rescue => e

      end
      json
    end.select { |f| not f.empty? }

    dashboard_info = {
      id: SecureRandom.uuid,
      report_fulfillment: report_fulfillment,
      report_ratios: report_ratios
    }

    dashboard = Dashboard.new dashboard_info

    render json: JSONAPI::ResourceSerializer.new(Api::V1::DashboardResource)
    .serialize_to_hash(Api::V1::DashboardResource.new(dashboard, nil))


  end



  def inverfact
    date = DateTime.now
    if params[:year].present? and params[:month].present?
      year = params.require(:year).to_i
      month = params.require(:month).to_i
      date = DateTime.new(year, month)
    end

    reports = Report.joins(creator: :role)
    .where(roles: { organization_id: current_user.organization_id })
    .where("reports.created_at >= ? AND reports.created_at <= ?",
           date.beginning_of_month,
           date.end_of_month
           )
    by_user = reports.group("users.id")
    .select("count(reports.id) AS num_reports, users.first_name || ' ' || users.last_name as user_name,
      count(distinct(dynamic_attributes->'94'->>'value')) AS num_companies")
    .map do |group|
      {
        user_name: group.user_name,
        num_reports: group.num_reports,
        num_companies: group.num_companies
      }
    end

    num_companies = reports
      .group("dynamic_attributes->'94'->>'value'")
      .select("count(dynamic_attributes->'94'->>'value') AS num_companies")
      .length

    by_reason = reports.group("dynamic_attributes->'95'->>'value'")
      .select("count(reports.id) AS num_reports, dynamic_attributes->'95'->>'value' AS reason")
      .order("count(reports.id) DESC")
      .map do |group|
        {
          num_reports: group.num_reports,
          reason: group.reason
        }
    end

    render json: {
      data: {
        id: "#{date.month}/#{date.year}",
        type: "dashboards",
        attributes: {
          reports_by_user: by_user,
          num_companies: num_companies,
          reports_by_reason: by_reason
        }
      }
    }

  end

  def idd_public
    date = DateTime.now
    reports = Report.joins(creator: :role)
    .where(roles: { organization_id: 6 })
    .where("reports.created_at >= ? AND reports.created_at <= ?",
           date.beginning_of_month,
           date.end_of_month
           )
    num_received = reports.count
    num_resolved = reports.where("reports.state_id = ?", 16).count

    images = []

    reports.where("state_id = ?", 16).includes(:images).order("reports.created_at DESC").each do |report|
      before_image = report.images.find { |i| i.state_id == 12 and i.selected? }
      after_image = report.images.find { |i| i.state_id == 13 and i.selected? }
      if before_image.present? and after_image.present?
        images << {
          image: before_image.url,
          type: "before",
          usuario: report.dynamic_attributes.dig("80", "value")
        }
        images << {
          image: after_image.url,
          type: "after",
          usuario: report.dynamic_attributes.dig("80", "value")
        }
      end
    end

    report_locations = []
    reports.includes(:initial_location).each do |report|
      report_locations << {
        id: report.id.to_s,
        name: report.dynamic_attributes.dig("78", "value"),
        position: [ report.initial_location.lonlat.y, report.initial_location.lonlat.x ],
        type: report.state_id == 16 ? 'resuelto' : 'recibido',
        color: report.state_id == 16 ? 'green' : 'orange'
      }
    end

    render json: {
      data: {
        id: "#{date.month}/#{date.year}",
        type: "dashboards",
        attributes: {
          num_received: num_received,
          num_resolved: num_resolved,
          images: images,
          report_locations: report_locations
        }
      }
    }

  end

  def idd_internal
    date = DateTime.now
    if params[:year].present? and params[:month].present?
      year = params.require(:year).to_i
      month = params.require(:month).to_i
      date = DateTime.new(year, month)
    end

    reports = Report.joins(creator: :role)
    .where(roles: { organization_id: current_user.organization_id })
    .where("reports.created_at >= ? AND reports.created_at <= ?",
           date.beginning_of_month,
           date.end_of_month
           )
    num_received = reports.count
    num_resolved = reports.where("reports.state_id = ?", 16).count

    by_category = reports.group("dynamic_attributes->'84'->>'value'")
    .where("dynamic_attributes->'84'->>'value' IS NOT NULL")
    .order("dynamic_attributes->'84'->>'value' ASC")
    .select("dynamic_attributes->'84'->>'value' AS category, count(reports.id) as num_reports")
    .map do |group|
      {
        name: group.category,
        num_reports: group.num_reports
      }
    end

    by_department = reports.group("dynamic_attributes->'83'->>'value'")
    .where("dynamic_attributes->'83'->>'value' IS NOT NULL")
    .order("dynamic_attributes->'83'->>'value' ASC")
    .select("dynamic_attributes->'83'->>'value' AS department, count(reports.id) as num_reports")
    .map do |group|
      {
        name: group.department,
        num_reports: group.num_reports
      }
    end

    report_locations = []
    reports.includes(:initial_location).each do |report|
      report_locations << {
        id: report.id.to_s,
        name: report.dynamic_attributes.dig("78", "value"),
        position: [ report.initial_location.lonlat.y, report.initial_location.lonlat.x ],
        type: report.state_id == 16 ? 'resuelto' : 'recibido',
        color: report.state_id == 16 ? 'green' : 'orange'
      }
    end

    render json: {
      data: {
        id: "#{date.month}/#{date.year}",
        type: "dashboards",
        attributes: {
          num_received: num_received,
          num_resolved: num_resolved,
          by_category: by_category,
          by_department: by_department,
          report_locations: report_locations
        }
      }
    }
  end

  def show
    if current_user.organization_id == 3
      show_manflas
      return
    end
    inspections = Api::V1::InspectionResource.records({
                                                        context: {
                                                          current_user: current_user,
                                                          dashboard: true
                                                        }
    })
    params[:filter] ||= {}
    filters = Api::V1::InspectionResource.verify_filters(params[:filter])

    inspections = Api::V1::InspectionResource.apply_filters(inspections,
                                                            filters)

    reports = Report.joins(:inspection)
    .where(inspections:  { id: inspections.map { |i| i.id }})

    report_ratios = [
      {
        state: "unchecked",
        num_reports: 0
      },
      {
        state: "resolved",
        num_reports: 0
      }
    ]
    sql_ratios = reports.group("reports.state").select("reports.state, count(reports.id) as num_reports").order("")
    .as_json.map do |json|
      json.delete "id"
      json
    end
    sql_ratios.each do |ratio|
      idx = ratio["state"] == "unchecked" ? 0 : 1
      report_ratios[idx]["num_reports"] = ratio["num_reports"]
    end

    state_names = Report.states.keys
    report_fulfillment = reports.joins(inspection: :construction).group("inspections.id, constructions.name, reports.state")
    .select("inspections.id as inspection_id, constructions.name as construction_name, reports.state, count(reports.id) as num_reports")
    .order("constructions.name ASC").group_by { |r| r.inspection_id.to_s + "-" + r.construction_name }.map do |construction_name, report_group|
      json = {
        inspection_id: construction_name.split('-')[1]
      }
      state_names.each do |state_name|
        json["num_" + state_name.to_s] = 0
      end
      report_group.each do |report|
        json["num_" + report.state] = report.num_reports
      end
      json
    end

    activity_names = Collection.find(1).collection_items.order("name ASC").map { |c| c['name'] }
    groups = Collection.find(4).collection_items.order("name ASC").map { |c| c['name'] }
    activity_groups = []
    activity_names.each do |name|
      activity_groups << Array.new(groups.length, 0)
    end

    if current_user.organization_id == 1
      riesgo_id = 8
      grupo_id = 3
    elsif current_user.organization_id == 2
      riesgo_id = 23
      grupo_id = 39
    end

    reports.group("dynamic_attributes->'#{grupo_id}'->>'text', dynamic_attributes->'#{riesgo_id}'->>'text'")
    .select("count(reports.id) as num_reports, dynamic_attributes->'#{grupo_id}'->>'text' as grupo_actividad, dynamic_attributes->'#{riesgo_id}'->>'text' as grado_riesgo")
    .group_by { |r| r.grupo_actividad }.each do |grupo_actividad, report_group|
      json = []
      groups.each do |group|
        json << 0
      end
      report_group.each do |report|
        index = groups.find_index do |group|
          group == report.grado_riesgo
        end
        json[index] = report.num_reports
      end


      activity_idx = activity_names.find_index do |activity_name|
        activity_name == grupo_actividad
      end
      activity_groups[activity_idx] = json

    end

    report_locations = [
      {
        state: "unchecked",
        coordinates: []
      },
      {
        state: "resolved",
        coordinates: []
      }
    ]
    sql_locations = reports.includes(:initial_location).group_by(&:state).map do |state, report_group|
      {
        state: state,
        coordinates: report_group.map do |report|
          json =
          {
            latitude: report.initial_location.lonlat.y.round(8),
            longitude: report.initial_location.lonlat.x.round(8)
          }

          json
        end
      }
    end
    sql_locations.each do |location|
      idx = location[:state] == "unchecked" ? 0 : 1
      report_locations[idx][:coordinates] = location[:coordinates]
    end

    dashboard_info = {
      id: SecureRandom.uuid,
      grupos_actividad_vs_riesgo: activity_groups,
      grupos_actividad: activity_names,
      grados_riesgo: groups,
      report_fulfillment: report_fulfillment,
      report_ratios: report_ratios,
      report_locations: report_locations,
    }

    dashboard = Dashboard.new dashboard_info

    render json: JSONAPI::ResourceSerializer.new(Api::V1::DashboardResource)
    .serialize_to_hash(Api::V1::DashboardResource.new(dashboard, nil))
  end


end
