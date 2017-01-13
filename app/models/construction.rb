# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: constructions
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  name            :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Construction < ApplicationRecord
  belongs_to :organization
  has_many :inspections
end
