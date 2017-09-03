# -*- encoding : utf-8 -*-
class Api::V1::StateResource < ApplicationResource
  attributes :name, :color, :show_pdf, :editable,
    :undoable
  has_many :previous_states
  has_many :next_states
  has_many :sections
  has_many :outgoing_transitions
  has_one :report_type
  add_foreign_keys :report_type_id

  def editable
    # VERY temp fix for IDD before role rework
    # Resolviendo
    current_user = context[:current_user]
    if @model.id == 13
    	# Resolutos
      current_user.role_id == 14
    # Terminando
  	elsif @model.id == 15
  		current_user.role_id == 13
  	else
  		true
    end
  end
end
