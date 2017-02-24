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
#

class Personnel < ApplicationRecord
  belongs_to :organization
  validates :organization, presence: true
  validates :name, presence: true
  validates :rut, presence: true, uniqueness: { scope: :organization }
  has_many :construction_personnel
  has_many :constructions, through: :construction_personnel
end
