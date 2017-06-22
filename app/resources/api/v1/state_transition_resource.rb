# -*- encoding : utf-8 -*-
class Api::V1::StateTransitionResource < ApplicationResource
  attributes :name
  has_one :previous_state
  has_one :next_state
  add_foreign_keys :previous_state_id, :next_state_id
end
