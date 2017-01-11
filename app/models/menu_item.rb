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
#
# Indexes
#
#  index_menu_items_on_menu_section_id  (menu_section_id)
#
# Foreign Keys
#
#  fk_rails_6ce18aef6c  (menu_section_id => menu_sections.id)
#

class MenuItem < ApplicationRecord
  belongs_to :menu_section
  has_and_belongs_to_many :roles
end
