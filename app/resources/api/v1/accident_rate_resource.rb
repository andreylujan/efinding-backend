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

  before_save do
    @model.organization = context[:current_user].organization if @model.new_record?
  end

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
