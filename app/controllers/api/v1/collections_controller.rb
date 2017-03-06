# -*- encoding : utf-8 -*-
class Api::V1::CollectionsController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!

  def show
    if params[:format] == "csv"
      collection = Collection.find(params.require(:id))
      send_data collection.to_csv, filename: "#{collection.name.parameterize.underscore}.csv",
        disposition: "attachment", type: "text/csv"
    else
      super
    end
  end
  
  def update
    if params[:format] == "csv"
      collection = Collection.find(params.require(:id))
      begin
        resources = collection.from_csv(params.require(:csv), current_user)
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
    else
      super
    end
  end
end
