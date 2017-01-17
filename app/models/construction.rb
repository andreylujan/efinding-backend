# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: constructions
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#

class Construction < ApplicationRecord
  belongs_to :company
  has_many :inspections
end
