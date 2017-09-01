# == Schema Information
#
# Table name: monthly_global_data
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  month_date      :date             not null
#  num_workers     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class MonthlyGlobalData < ApplicationRecord
  belongs_to :organization
  validates :organization, presence: true
  validates :month_date, presence: true, uniqueness: { scope: :organization_id }
  validates :num_workers, presence: true
end
