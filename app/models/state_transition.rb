# == Schema Information
#
# Table name: state_transitions
#
#  id                :integer          not null, primary key
#  previous_state_id :integer          not null
#  next_state_id     :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :text             not null
#

class StateTransition < ApplicationRecord
	belongs_to :previous_state, class_name: :State, foreign_key: :previous_state_id
	belongs_to :next_state, class_name: :State, foreign_key: :next_state_id
	validates :previous_state, presence: true
	validates :next_state, presence: true
end
