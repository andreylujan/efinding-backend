class Api::V1::AccidentRateResource < ApplicationResource
  attributes :month,
    :man_hours,
    :worker_average,
    :num_accidents,
    :num_days_lots,
    :accident_rate,
    :casualty_rate,
    :frequency_index,
    :gravity_index
  has_one :construction

  def self.updatable_fields(context)
    super - [ :frequency_index, :gravity_index ]
  end

  def self.creatable_fields(context)
    super - [ :frequency_index, :gravity_index ]
  end
end
