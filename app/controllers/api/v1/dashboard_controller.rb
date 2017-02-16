# -*- encoding : utf-8 -*-
class Api::V1::DashboardController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!

  def show

    inspections = Api::V1::InspectionResource.records({
                                                        context: {
                                                          current_user: current_user
                                                        }
    })

    filters = Api::V1::InspectionResource.verify_filters(params[:filter])

    inspections = Api::V1::InspectionResource.apply_filters(inspections,
                                                            filters)

    reports = Report.joins(:inspection)
    .where(inspections:  { id: inspections.map { |i| i.id }})

    report_ratios = reports.group("reports.state").select("reports.state, count(reports.id) as num_reports").order("")
    .as_json.map do |json|
      json.delete "id"
      json
    end
    state_names = Report.states.keys
    report_fulfillment = reports.group("inspections.id, reports.state")
    .select("inspections.id as inspection_id, reports.state, count(reports.id) as num_reports")
    .order("").group_by { |r| r.inspection_id }.map do |inspection_id, report_group|
      json = {
        inspection_id: inspection_id
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

    activity_groups = reports.group("dynamic_attributes->'3'->>'text', dynamic_attributes->'8'->>'text'")
    .select("count(reports.id) as num_reports, dynamic_attributes->'3'->>'text' as grupo_actividad, dynamic_attributes->'8'->>'text' as grado_riesgo")
    .group_by { |r| r.grupo_actividad }.map do |grupo_actividad, report_group|
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
      json

    end

    report_locations = reports.includes(:initial_location).group_by(&:state).map do |state, report_group|
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
