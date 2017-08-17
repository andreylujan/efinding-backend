# -*- encoding : utf-8 -*-
class Api::V1::Idd::ReportsController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!
  def summaries
    reports = Report.joins(creator: :role)
    .where(roles: { organization_id: current_user.organization_id })
    .order("created_at DESC")

    if params[:start_date].present?
      start_date = params[:start_date]
      parts = start_date.split("/").map { |s| s.to_i }
      start_date = DateTime.new(parts[2], parts[1], parts[0])
      reports = reports.where("reports.created_at >= ?", start_date)
    end

    if params[:end_date].present?
      end_date = params[:end_date]
      parts = end_date.split("/").map { |s| s.to_i }
      end_date = DateTime.new(parts[2], parts[1], parts[0])
      reports = reports.where("reports.created_at <= ?", end_date.end_of_day)
    end

    by_email = {}
    reports.each do |report|
      if email = report.dynamic_attributes.dig("81", "value").strip.downcase.gsub("\"", "").gsub("'", "")
        if by_email[email]
          by_email[email][:num_reports] += 1
        else
          by_email[email] = {
            id: report.id.to_s,
            num_reports: 1,
            email: email,
            name: report.dynamic_attributes.dig("80", "value"),
            phone: report.dynamic_attributes.dig("82", "value")
          }
        end
      end
    end

    reports = by_email.map do |key, value|
      Api::V1::Idd::ReportSummaryResource.new(
        ::Idd::ReportSummary.new({
                                   id: value[:id],
                                   email: value[:email],
                                   num_reports: value[:num_reports],
                                   name: value[:name],
                                   phone: value[:phone]
        }), nil
      )
    end

    render json: JSONAPI::ResourceSerializer.new(Api::V1::Idd::ReportSummaryResource)
    .serialize_to_hash(reports)

  end
end
