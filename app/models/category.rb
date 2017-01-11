# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  name            :text             not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_categories_on_organization_id           (organization_id)
#  index_categories_on_organization_id_and_name  (organization_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_8fa20c9b22  (organization_id => organizations.id)
#

class Category < ApplicationRecord
  belongs_to :organization
  has_many :images
end
