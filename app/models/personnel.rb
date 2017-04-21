# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: personnel
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  rut             :text             not null
#  name            :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  email           :text
#

class Personnel < ApplicationRecord
  belongs_to :organization
  validates :organization, presence: true
  validates :name, presence: true
  validates :rut, presence: true, uniqueness: { scope: :organization }
  has_many :construction_personnel
  has_many :constructions, through: :construction_personnel
  has_many :personnel_types, through: :construction_personnel

  # validate :correct_rut
  before_save :format_rut

  def correct_rut
    if rut.present?
      unless RUT::validar(self.rut)
        errors.add(:rut, "Formato de RUT inválido")
      end
    end
  end

  def format_rut
    if rut.present? and RUT::validar(rut)
      self.rut = RUT::formatear(RUT::quitarFormato(self.rut).gsub(/^0+|$/, ''))
    end
  end

end
