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
#

class Company < ApplicationRecord
  belongs_to :organization
  validates :organization, presence: true
  validates :name, presence: true, uniqueness: { scope: :organization }
  has_many :constructions
end
