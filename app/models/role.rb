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

class Role < ApplicationRecord
  belongs_to :organization
  has_many :users
  has_and_belongs_to_many :menu_items
end
