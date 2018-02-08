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
      Rails.logger.info "ID collection : #{params.require(:id)}"
      collection_id = params.require(:id)
      collection = Collection.find(params.require(:id))
      begin
        if collection_id == "46"
          Rails.logger.info "from_csv_intralot"
          resources = collection.from_csv_intralot(params.require(:csv), current_user)
        else
          Rails.logger.info "from_csv"
          resources = collection.from_csv(params.require(:csv), current_user)
        end
      rescue => exception
        render json: {
          errors: [
            status: '400',
            detail: exception.class.to_s + ": " + exception.message
          ]
        }, status: :bad_request
        return
      end
      Rails.logger.info "Response : #{resources}"
      render json: CsvUploadSerializer.serialize(resources, is_collection: true)
    else
      super
    end
  end
end
