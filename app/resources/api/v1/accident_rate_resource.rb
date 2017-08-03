# -*- encoding : utf-8 -*-
class Api::V1::AccidentRateResource < ApplicationResource
  attributes :month,
    :year,
    :man_hours,
    :worker_average,
    :num_accidents,
    :num_days_lost,
    :accident_rate,
    :casualty_rate,
    :frequency_index,
    :gravity_index
    
  has_one :construction

  def month
    @model.rate_period.month
  end

  def year
    @model.rate_period.year
  end

  before_save do
    @model.organization = context[:current_user].organization if @model.new_record?
  end

  filter :construction_id, apply: ->(records, value, _options) {
    if not value.empty?
      records.where(construction_id: value[0])
    else
      records
    end
  }

  filter :period, apply: ->(records, value, _options) {
    if not value.empty?
      date_str = value[0].split("/")
      year = date_str[1].to_i
      month = date_str[0].to_i
      rate_period = Date.new(year, month)
      records.where("rate_period >= ? AND rate_period <= ?", rate_period - 3.months, rate_period - 1.month)
    else
      records
    end
  }

  filter :company_id, apply: ->(records, value, _options) {
    if not value.empty?
      records.joins(:construction)
          .where(constructions: { company_id: value[0] })
    else
      records
    end
  }

  def year
    @model.rate_period.year
  end

  def month
    @model.rate_period.month
  end

  def self.updatable_fields(context)
    super - [ :frequency_index, :gravity_index ]
  end

  def self.creatable_fields(context)
    super - [ :frequency_index, :gravity_index ]
  end

  def self.records(options = {})
    context = options[:context]
    current_user = context[:current_user]
    AccidentRate.where(organization_id: current_user.organization_id)
  end
end
