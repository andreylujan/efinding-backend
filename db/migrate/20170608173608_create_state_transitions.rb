class CreateStateTransitions < ActiveRecord::Migration[5.0]
  def change
    create_table :state_transitions do |t|
      t.integer :previous_state_id, null: false
      t.integer :next_state_id, null: false

      t.timestamps
    end
    add_index :state_transitions, [ :previous_state_id, :next_state_id ], unique: true
    add_index :state_transitions, [ :next_state_id, :previous_state_id ], unique: true

    add_foreign_key :state_transitions, :states, column: :previous_state_id
    add_foreign_key :state_transitions, :states, column: :next_state_id
  end
end
