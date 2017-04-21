# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: companies
#
#  id              :integer          not null, primary key
#  name            :text
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  rut             :text
#  deleted_at      :datetime
#

class Company < ApplicationRecord
  acts_as_paranoid
  belongs_to :organization
  validates :organization, presence: true
  validates :name, presence: true, uniqueness: { scope: :organization }
  has_many :constructions, dependent: :destroy

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
