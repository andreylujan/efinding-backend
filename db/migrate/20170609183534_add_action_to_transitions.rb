# -*- encoding : utf-8 -*-
class AddActionToTransitions < ActiveRecord::Migration[5.0]
  def change
    add_column :state_transitions, :action, :text
    StateTransition.all.each do |transition|
      transition.action = "Resolver"
      transition.save!
    end
    change_column :state_transitions, :action, :text, null: false
  end
end
