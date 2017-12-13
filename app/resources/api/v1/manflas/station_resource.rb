# -*- encoding : utf-8 -*-
class Api::V1::Manflas::StationResource < JSONAPI::Resource
  attributes :name,
  			:coordinates,
  			:sector,
  			:variety,
  			:polygon,
  			:style,
        :num_reports,
        :plantation_year,
        :plantation_density,
        :last_year_production,
        :water_precipitation,
        :performance

  def num_reports
    if context[:report_counts].present?
      context[:report_counts][@model.id.to_s] || 0
    else
      0
    end
  end

  model_name "::Manflas::Station"

  def self.find_count(filters, options = {})
    filter_records(filters, options).count
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    context[:report_counts] = Report.joins(creator: :role).
      where(roles: { organization_id: 3 })
      .group("dynamic_attributes->>'station_id'")
      .count

    if current_user.organization_id == 3
      ::Manflas::Station.all
    else
      ::Manflas::Station.none
    end
  end

end
