# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: contractors
#
#  id              :integer          not null, primary key
#  name            :text             not null
#  rut             :text             not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Contractor < ApplicationRecord
  belongs_to :organization
  validates :name, presence: true
  validates :rut, presence: true, uniqueness: { scope: :organization }
  validates :organization, presence: true
  has_and_belongs_to_many :constructions

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
