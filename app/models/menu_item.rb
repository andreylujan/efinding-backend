# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: menu_items
#
#  id              :integer          not null, primary key
#  menu_section_id :integer
#  name            :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  admin_path      :text
#  position        :integer
#  collection_name :text
#  url_include     :text
#  collection_id   :integer
#

class MenuItem < ApplicationRecord
  belongs_to :menu_section
  acts_as_list scope: :menu_section
  has_and_belongs_to_many :roles
end
