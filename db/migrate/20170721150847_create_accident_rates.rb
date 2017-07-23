class CreateAccidentRates < ActiveRecord::Migration[5.0]
  def change
    create_table :accident_rates do |t|
      t.references :construction, foreign_key: true, null: false
      t.date :month, null: false
      t.float :man_hours
      t.float :worker_average
      t.integer :num_accidents
      t.integer :num_days_lost
      t.float :accident_rate
      t.float :casualty_rate
      t.float :frequency_index
      t.float :gravity_index

      t.timestamps
    end
  end
end
