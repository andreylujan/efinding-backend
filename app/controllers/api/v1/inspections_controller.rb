# -*- encoding : utf-8 -*-
class Api::V1::InspectionsController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!

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
