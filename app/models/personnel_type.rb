# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: personnel_types
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  name            :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class PersonnelType < ApplicationRecord
  belongs_to :organization
  validates :organization, presence: true
  validates :name, presence: true, uniqueness: { scope: :organization }
end
