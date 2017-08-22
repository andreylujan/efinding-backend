# -*- encoding : utf-8 -*-
class Api::V1::DashboardController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!, except: [ :idd_public ]

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
