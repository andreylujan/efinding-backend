# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: sections
#
#  id           :integer          not null, primary key
#  position     :integer
#  name         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  section_type :integer
#  config       :json             not null
#  state_id     :integer
#

class Section < ApplicationRecord
  belongs_to :state
  acts_as_list scope: :state
  has_many :data_parts, -> { order(position: :asc) }
  enum section_type: [ :location, :gallery, :data_parts ]
end
