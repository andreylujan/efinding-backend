# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: constructions
#
#  id               :integer          not null, primary key
#  name             :text             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  company_id       :integer
#  administrator_id :integer
#  code             :text
#  expert_id        :integer
#

class Construction < ApplicationRecord
  belongs_to :company
  has_many :inspections
  validates :company, presence: true
  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :company }
  belongs_to :administrator, class_name: :User, foreign_key: :administrator_id
  belongs_to :expert, class_name: :User, foreign_key: :expert_id
  # belongs_to :visitor, class_name: :Person, foreign_key: :visitor_id
  has_and_belongs_to_many :contractors
  has_many :construction_personnel
  accepts_nested_attributes_for :construction_personnel
  has_many :personnel, through: :construction_personnel

  def construction_personnel_attributes=(val)
    self.construction_personnel.each { |p| p.destroy! }
    super
  end
end
