# -*- encoding : utf-8 -*-
class Api::V1::DashboardController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!
  def show
    yearly_reports = filter_by_organization(Report
                                            .includes(:assigned_user, :creator)
                                            .where("reports.created_at >= ? AND reports.created_at < ?",
                                                   DateTime.now.beginning_of_year, DateTime.now.end_of_year)
                                            .order('reports.created_at ASC'))
    filtered_reports = yearly_reports
    reports_by_month = filtered_reports.group_by(&:month_criteria).map do |month|
    	
    	{
    		num_assigned: month[1].count { |r| r.assigned_user.present? },
        num_executed: month[1].count { |r| r.finished? },
        month_name: I18n.l(month[0], format: '%B').capitalize

    	}
    end

    current_month_user_reports = filtered_reports.where("reports.created_at >= ? AND reports.created_at < ?",
        DateTime.now.beginning_of_month, DateTime.now.end_of_month)
        # .where.not(assigned_user_id: nil)

    current_month_reports_by_user = current_month_user_reports.where.not(assigned_user_id: nil).group_by(&:assigned_user).map do |info|
      {
        user_name: info[0].name,
        num_assigned_reports: info[1].length,
        num_executed_reports: info[1].count { |r| r.finished? }
      }
    end.sort! { |a, b| a[:user_name] <=> b[:user_name] }

    last_month_user_reports = filtered_reports.where("reports.created_at >= ? AND reports.created_at < ?",
        DateTime.now.beginning_of_month - 1.month, DateTime.now.end_of_month - 1.month)
        # .where.not(assigned_user_id: nil)

    last_month_reports_by_user = last_month_user_reports.where.not(assigned_user_id: nil).group_by(&:assigned_user).select { |x| x.present? }.map do |info|
      {
        user_name: info[0].name,
        num_assigned_reports: info[1].length,
        num_executed_reports: info[1].count { |r| r.finished? }
      }
    end.sort! { |a, b| a[:user_name] <=> b[:user_name] }

    report_counts = {
      num_last_month: last_month_user_reports.count,
      num_current_month: current_month_user_reports.count
    }

    dashboard_info = {
      id: SecureRandom.uuid,
      report_counts: report_counts,
      reports_by_month: reports_by_month,
      last_month_reports_by_user: last_month_reports_by_user,
      current_month_reports_by_user: current_month_reports_by_user
    }

    dashboard = Dashboard.new dashboard_info
    
    render json: JSONAPI::ResourceSerializer.new(Api::V1::DashboardResource)
    .serialize_to_hash(Api::V1::DashboardResource.new(dashboard, nil))

    


  end

  def filter_by_organization(reports = nil)
    if reports.nil?
      Report.joins(creator: :role)
      .where(roles: { organization_id: current_user.organization_id })
    else
      reports.joins(creator: :role)
      .where(roles: { organization_id: current_user.organization_id })
    end
  end

end
