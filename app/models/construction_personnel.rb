# == Schema Information
#
# Table name: construction_personnel
#
#  id                :integer          not null, primary key
#  construction_id   :integer          not null
#  personnel_id      :integer          not null
#  personnel_type_id :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class ConstructionPersonnel < ApplicationRecord
  belongs_to :construction
  belongs_to :personnel
  belongs_to :personnel_type

  validates :construction, presence: true
  validates :personnel, presence: true
  validates :personnel_type, presence: true
end
