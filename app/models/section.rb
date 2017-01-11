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

class Section < ApplicationRecord
  belongs_to :section_type
  belongs_to :report_type
  acts_as_list scope: :report_type
  has_many :data_parts, -> { order(position: :asc) }
  has_many :checklist_options, class_name: :ChecklistOption, foreign_key: :detail_id
  delegate :organization, to: :report_type, allow_nil: false
end
