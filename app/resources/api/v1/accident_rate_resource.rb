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

  def year
  end

  def month
  end

  def self.updatable_fields(context)
    super - [ :frequency_index, :gravity_index ]
  end

  def self.creatable_fields(context)
    super - [ :frequency_index, :gravity_index ]
  end
end
