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
#
# Indexes
#
#  index_menu_sections_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_f5aa4563e9  (organization_id => organizations.id)
#

class MenuSection < ApplicationRecord
  belongs_to :organization

  has_many :menu_items
end
