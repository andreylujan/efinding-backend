# -*- encoding : utf-8 -*-
class AddIsLocalToStateTransitions < ActiveRecord::Migration[5.0]
  def change
    add_column :state_transitions, :is_local, :boolean, null: false, default: false
  end
end
