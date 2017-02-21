# == Schema Information
#
# Table name: checklists
#
#  id              :integer          not null, primary key
#  name            :text
#  sections        :json             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer          not null
#

class Checklist < ApplicationRecord
  belongs_to :organization
  validates :organization, presence: true, uniqueness: true
end
