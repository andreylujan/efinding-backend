# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: inspections
#
#  id              :integer          not null, primary key
#  construction_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Inspection < ApplicationRecord
  belongs_to :construction
  has_many :reports
end