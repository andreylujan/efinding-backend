# -*- encoding : utf-8 -*-
class Api::V1::InspectionsController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!

  def index
    if params[:format] == "xlsx"
      get_excel
      return
    end
    super
  end

  def get_excel
    package = Axlsx::Package.new
    Inspection.to_xlsx(package: package)
    Report.to_xlsx(package: package)
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
