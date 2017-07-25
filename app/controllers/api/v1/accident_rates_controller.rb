class Api::V1::AccidentRatesController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!

  def index_csv
    send_data AccidentRate.to_csv(current_user, nil), filename: "accidentabilidad.csv",
      disposition: "attachment", type: "text/csv"
  end

  def create_csv
    begin
      resources = AccidentRate.from_csv(params.require(:csv), current_user)
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
