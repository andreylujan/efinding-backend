# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: inspections
#
#  id              :integer          not null, primary key
#  construction_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :integer
#  resolved_at     :datetime
#

class Inspection < ApplicationRecord
  belongs_to :construction
  has_many :reports
  belongs_to :creator, class_name: :User, foreign_key: :creator_id
  validates :construction, presence: true
end
