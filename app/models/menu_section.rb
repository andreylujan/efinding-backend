# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: menu_sections
#
#  id              :integer          not null, primary key
#  name            :text             not null
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  icon            :text
#  admin_path      :text
#  position        :integer
#

class MenuSection < ApplicationRecord
  belongs_to :organization
  acts_as_list scope: :organization
  has_many :menu_items, -> { order(position: :asc) }, dependent: :destroy
end
