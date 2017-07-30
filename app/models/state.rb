# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: states
#
#  id             :integer          not null, primary key
#  name           :text             not null
#  report_type_id :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  color          :text
#  show_pdf       :boolean          default(TRUE), not null
#

class State < ApplicationRecord
  belongs_to :report_type
  validates :report_type, presence: true
  validates :name, presence: true, uniqueness: { scope: :report_type }
  has_many :incoming_transitions, class_name: :StateTransition, foreign_key: :next_state_id
  has_many :outgoing_transitions, class_name: :StateTransition, foreign_key: :previous_state_id
  has_many :previous_states, through: :incoming_transitions
  has_many :next_states, through: :outgoing_transitions
  has_many :sections
  has_many :reports
end
