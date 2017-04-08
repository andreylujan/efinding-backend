# -*- encoding : utf-8 -*-
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

  validate :correct_organization

  private
  def correct_organization
    org = construction.company.organization
    if org != personnel.organization
      errors.add(:personnel, "El personal no pertenece a la misma organización que la obra")
    end
    if org != personnel_type.organization
      errors.add(:personnel_type, "El tipo de personal no pertenece a la misma organización que la obra")
    end
  end
end
