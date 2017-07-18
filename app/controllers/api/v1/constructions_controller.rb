# -*- encoding : utf-8 -*-
class Api::V1::ConstructionsController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!

  def update
    params.permit!
    if personnel = params.dig("data", "attributes", "construction_personnel_attributes")
      personnel.each do |p|
        p["construction_id"] = params[:id]
      end
    end

    super
  end

  def index
    if params[:company_id].present?
      fields = {}
      if params[:fields].present?
        fields = params[:fields]
      end
      fields[:constructions] = "name,company_id,code,administrator_id,expert_id,supervisor_id,expert,administrator,contractors"
      params[:fields] = fields
    end
    super
  end

  def get_csv
    send_data Construction.to_csv(current_user, nil), filename: "obras.csv",
      disposition: "attachment", type: "text/csv"
  end

  def create_csv
    begin
      resources = Construction.from_csv(params.require(:csv), current_user)
    rescue => exception
      render json: {
        errors: [
          status: '400',
          detail: exception.class.to_s + ": " + exception.message
        ]
      }, status: :bad_request
      return
    end
    render json: CsvUploadSerializer.serialize(resources, is_collection: true)
  end

  def get_personnel
    send_data Construction.personnel_to_csv(nil, current_user), filename: "personal_de_obra.csv",
      disposition: "attachment", type: "text/csv"
  end

  def create_personnel
    begin
      resources = Construction.personnel_from_csv(params.require(:csv), current_user)
    rescue => exception
      render json: {
        errors: [
          status: '400',
          detail: exception.class.to_s + ": " + exception.message
        ]
      }, status: :bad_request
      return
    end
    render json: CsvUploadSerializer.serialize(resources, is_collection: true)
  end

  def context
    {
      current_user: current_user,
      company_id: params[:company_id]
    }
  end

end
