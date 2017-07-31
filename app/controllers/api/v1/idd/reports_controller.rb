# -*- encoding : utf-8 -*-
class Api::V1::Idd::ReportsController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!
  def summaries
    reports = Report.joins(creator: :role)
      .where(roles: { organization_id: current_user.organization_id })
      .group("dynamic_attributes -> '81' ->> 'value',
        dynamic_attributes -> '82' ->> 'value',
        dynamic_attributes -> '80' ->> 'value'")
      .select("count(reports.id) as num_reports,
        dynamic_attributes -> '80' ->> 'value' as name,
          dynamic_attributes -> '81' ->> 'value' as email,
          dynamic_attributes -> '82' ->> 'value' as phone")
      .order("dynamic_attributes -> '81' ->> 'value'  ASC")
      .map do |group|
        Api::V1::Idd::ReportSummaryResource.new(
          ::Idd::ReportSummary.new({
            id: group.email,
            email: group.email,
            num_reports: group.num_reports,
            name: group.name,
            phone: group.phone
          }), nil
        )
      end
      
      render json: JSONAPI::ResourceSerializer.new(Api::V1::Idd::ReportSummaryResource)
        .serialize_to_hash(reports)

  end
end
