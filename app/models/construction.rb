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
#  visitor_id       :integer
#  code             :text
#

class Construction < ApplicationRecord
  belongs_to :company
  has_many :inspections
  validates :company, presence: true
  validates :name, presence: true, uniqueness: { scope: :company }
  belongs_to :administrator, class_name: :Person, foreign_key: :administrator_id
  belongs_to :visitor, class_name: :Person, foreign_key: :visitor_id
  has_and_belongs_to_many :contractors, class_name: "Person", foreign_key: :person_id
end
