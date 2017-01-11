# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: roles
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  name            :text             not null
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_roles_on_organization_id           (organization_id)
#  index_roles_on_organization_id_and_name  (organization_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_2f99738edd  (organization_id => organizations.id)
#

class Role < ApplicationRecord
  belongs_to :organization
  has_many :users
  has_and_belongs_to_many :menu_items
end
