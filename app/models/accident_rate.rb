# == Schema Information
#
# Table name: accident_rates
#
#  id              :integer          not null, primary key
#  construction_id :integer          not null
#  month           :date             not null
#  man_hours       :float
#  worker_average  :float
#  num_accidents   :integer
#  num_days_lost   :integer
#  accident_rate   :float
#  casualty_rate   :float
#  frequency_index :float
#  gravity_index   :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AccidentRate < ApplicationRecord
  attr_accessor :month
  attr_accessor :year
  belongs_to :construction
  validates :rate_period, presence: true
  validates :man_hours, presence: true
  validates :worker_average, presence: true
  validates :num_accidents, presence: true
  validates :num_days_lost, presence: true
  validates :accident_rate, presence: true
  validates :casualty_rate, presence: true
  validates :construction, presence: true
  validates :rate_period, uniqueness: { scope: :construction }

  before_validation :set_period
  before_save :calculate_indexes

  private
  def set_period
    if year.present? and month.present?
      self.rate_period = Date.new(year.to_i, month.to_i)
    end
  end

  def calculate_indexes
  	self.gravity_index = 1.5
  	self.frequency_index = 2.1
  end
end
