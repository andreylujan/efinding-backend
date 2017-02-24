# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: sections
#
#  id             :integer          not null, primary key
#  position       :integer
#  name           :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  report_type_id :integer
#  section_type   :integer
#  config         :json             not null
#

class Section < ApplicationRecord
  belongs_to :report_type
  acts_as_list scope: :report_type
  has_many :data_parts, -> { order(position: :asc) }
  delegate :organization, to: :report_type, allow_nil: false
  enum section_type: [ :location, :gallery, :data_parts ]
end
