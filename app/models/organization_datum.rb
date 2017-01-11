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
# Indexes
#
#  index_organization_data_on_organization_id                      (organization_id)
#  index_organization_data_on_organization_id_and_collection_name  (organization_id,collection_name) UNIQUE
#  index_organization_data_on_organization_id_and_path_suffix      (organization_id,path_suffix) UNIQUE
#
# Foreign Keys
#
#  fk_rails_fb596a91bb  (organization_id => organizations.id)
#

class OrganizationDatum < ApplicationRecord
  belongs_to :organization
  validates :organization, presence: true
  validates :path_suffix, presence: true, uniqueness: true
  validates :collection_name, presence: true, uniqueness: true
end
