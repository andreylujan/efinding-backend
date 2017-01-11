# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: sections
#
#  id              :integer          not null, primary key
#  position        :integer
#  name            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  section_type_id :integer          not null
#  report_type_id  :integer
#
# Indexes
#
#  index_sections_on_report_type_id   (report_type_id)
#  index_sections_on_section_type_id  (section_type_id)
#
# Foreign Keys
#
#  fk_rails_79ab8015ac  (section_type_id => section_types.id)
#  fk_rails_8f2fbe50f3  (report_type_id => report_types.id)
#

class Section < ApplicationRecord
  belongs_to :section_type
  belongs_to :report_type
  acts_as_list scope: :report_type
  has_many :data_parts, -> { order(position: :asc) }
  has_many :checklist_options, class_name: :ChecklistOption, foreign_key: :detail_id
  delegate :organization, to: :report_type, allow_nil: false
end
