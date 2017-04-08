# -*- encoding : utf-8 -*-
class Api::V1::DashboardController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!

  def show

    inspections = Api::V1::InspectionResource.records({
                                                        context: {
                                                          current_user: current_user,
                                                          dashboard: true
                                                        }
    })

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
