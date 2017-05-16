# -*- encoding : utf-8 -*-
class Api::V1::InspectionsController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!

  def index
    if params[:format] == "xlsx"
      @month = params.require(:month).to_i
      @year = params.require(:year).to_i
      get_excel
      return
    end
    super
  end

  def get_excel
    package = Axlsx::Package.new
    start_date = DateTime.new(@year, @month)
    end_date = start_date.end_of_month

    inspections = Inspection.joins(creator: :role)
      .includes(:creator, :initial_signer, :final_signer)
      .includes(construction: :company)
      .where(roles: { organization_id: current_user.organization_id })
      .where("inspections.created_at >= ? AND inspections.created_at <= ?", start_date, end_date)
      .order("inspections.created_at ASC")

    reports = Report.joins(creator: :role)
      .includes(:creator, :assigned_user)
      .where(roles: { organization_id: current_user.organization_id })
      .where("reports.created_at >= ? AND reports.created_at <= ?", start_date, end_date)
      .order("reports.created_at ASC")
    Inspection.setup_xlsx
    inspections.to_xlsx(package: package)
    Report.setup_xlsx(current_user.organization_id)
    reports.to_xlsx(package: package)
    send_data package.to_stream.read, filename: "inspecciones_reportes.xlsx",
        disposition: "attachment", type: "application/vnd.ms-excel"
  end

  def transition
    @inspection = Inspection.find(params.require(:id))
    transition_name = params.require(:transition_name)
    @inspection.send(transition_name + "!")
    if @inspection.state == "first_signature_done"
      @inspection.update_attributes! initial_signer: current_user
    elsif @inspection.state == "finished"
      @inspection.update_attributes! final_signer: current_user
    end
    @inspection.regenerate_all_pdfs
    render json: JSONAPI::ResourceSerializer.new(Api::V1::InspectionResource)
    .serialize_to_hash(Api::V1::InspectionResource.new(@inspection, nil))
  end
end
