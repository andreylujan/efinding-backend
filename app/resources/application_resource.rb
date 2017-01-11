# -*- encoding : utf-8 -*-
class ApplicationResource < JSONAPI::Resource
  def custom_links(options)
    {self: nil}
  end

  def self.apply_filters(records, filters, options = {})
    required_includes = []

    if filters
      filters.each do |filter, value|
        records = apply_filter(records, filter, value, options)
      end
    end

    if required_includes.any?
      records = apply_includes(records, options.merge(include_directives: IncludeDirectives.new(self, required_includes, force_eager_load: true)))
    end

    records
  end

  def self.apply_filter(records, filter, value, options)
    strategy = _allowed_filters.fetch(filter.to_sym, Hash.new)[:apply]
    if not _model_class.respond_to? :column_for_attribute
      return records
    end
    
    column = _model_class.column_for_attribute(filter)
    if column.present?
      if column.type == :text
        if value.is_a?(Array)
          value.each do |val|
            records = records.where("#{filter} ILIKE '%#{val}%'")
          end
        end
      else
        records = super(records, filter, value)
      end
    else
      if strategy
        if strategy.is_a?(Symbol) || strategy.is_a?(String)
          records = send(strategy, records, value, options)
        else
          records = strategy.call(records, value, options)
        end
      else
        records.where(filter => value)
      end
    end
    records
  end
end
