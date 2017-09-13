# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: app_menu_items
#
#  id                   :integer          not null, primary key
#  organization_id      :integer          not null
#  name                 :text             not null
#  position             :integer
#  icon                 :text
#  url_include          :text             not null
#  filter_creator       :boolean          default(FALSE), not null
#  filter_assigned_user :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class AppMenuItem < ApplicationRecord
  belongs_to :organization
  acts_as_list scope: :organization
end
