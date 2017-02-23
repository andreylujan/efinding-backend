# -*- encoding : utf-8 -*-
class Api::V1::CollectionsController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!

  def show
    if params[:format] == "csv"
      collection = Collection.find(params.require(:id))
      send_data collection.to_csv, filename: "maestro.csv",
        disposition: "attachment", type: "text/csv"
    else
      super
    end
  end

  def update
    if params[:format] == "csv"
      collection = Collection.find(params.require(:id))
      collection.from_csv(params.require(:csv))
    else
    	super
    end
  end
end
