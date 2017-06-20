# -*- encoding : utf-8 -*-
class Api::V1::StateTransitionResource < JSONAPI::Resource
  attributes :name
  has_one :previous_state
  has_one :next_state
end
