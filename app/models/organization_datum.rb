# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: organization_data
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  path_suffix     :text             not null
#  collection_name :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class OrganizationDatum < ApplicationRecord
  belongs_to :organization
  validates :organization, presence: true
  validates :path_suffix, presence: true, uniqueness: true
  validates :collection_name, presence: true, uniqueness: true
end
