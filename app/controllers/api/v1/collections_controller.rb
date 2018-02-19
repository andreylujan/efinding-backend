# -*- encoding : utf-8 -*-
class Api::V1::CollectionsController < Api::V1::JsonApiController
  before_action :doorkeeper_authorize!

  def show
    if params[:format] == "csv"
      collection = Collection.find(params.require(:id))
      if params.require(:id) == "46"
        send_data collection.to_csv_intralot, filename: "#{collection.name.parameterize.underscore}.csv",
          disposition: "attachment", type: "text/csv"
      else
        send_data collection.to_csv, filename: "#{collection.name.parameterize.underscore}.csv",
          disposition: "attachment", type: "text/csv"
      end
    else
      Rails.logger.info "Parametros: #{params}"
      if params.require(:id) == "46"
        render_intralot(params.require(:id))
        #super
      else
        super
      end
    end
  end
  def render_intralot(id)
    collection = Collection.find(id)
    Rails.logger.info "CollectionJson: #{collection.as_json}"
    #csv << [item.code, item.name.split('-')[1].strip, address, item.name.split('-')[2].strip]
    collection_items_data = []
    collection.collection_items.each do |item|
      collection_items_data << {type: "collection_items", id:item.id}
    end
    included_collection_items = []
    collection.collection_items.each do |item|
      address = CollectionItem.find_by("code = 'LT#{item.code}'").name
      included_collection_items << {id:item.id ,type: "collection_items",
        attributes: {parent_item_id: nil, collection_id: item.collection_id,
          name:  "#{item.name.clone.split(/-/).take(2).join('- ').strip} - #{address} - #{item.name.split('-')[2].strip}"}}
    end
    render json: {
      data:{
        id: collection.id,
        type: "collections",
        attributes: { name: collection.name , parent_collection_id: collection.parent_collection_id},
        relationships: { parent_collection: nil, collection_items: {data: collection_items_data} }
      },
      included: included_collection_items
    }
  end
  def update
    if params[:format] == "csv"
      Rails.logger.info "ID collection : #{params.require(:id)}"
      collection_id = params.require(:id)
      collection = Collection.find(params.require(:id))
      begin
        if collection_id == "46"
          resources = collection.from_csv_intralot(params.require(:csv), current_user)
        else
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
      render json: {data:resources}
      super
    end
  end
end
