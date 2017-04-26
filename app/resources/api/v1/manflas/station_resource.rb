class Api::V1::Manflas::StationResource < JSONAPI::Resource
  attributes :name,
  			:coordinates,
  			:sector,
  			:variety,
  			:polygon,
  			:style

  model_name "::Manflas::Station"

  def self.find_count(filters, options = {})
    filter_records(filters, options).count
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    ::Manflas::Station.all
  end

end
