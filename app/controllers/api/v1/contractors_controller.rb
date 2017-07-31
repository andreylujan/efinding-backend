# -*- encoding : utf-8 -*-
class Api::V1::ContractorsController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!
  def get_csv
    send_data Contractor.to_csv(current_user, nil), filename: "contratistas.csv",
      disposition: "attachment", type: "text/csv"
  end

  def create_csv
    begin
      resources = Contractor.from_csv(params.require(:csv), current_user)
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
end
