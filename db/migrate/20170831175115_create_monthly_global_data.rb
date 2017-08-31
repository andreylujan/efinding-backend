class CreateMonthlyGlobalData < ActiveRecord::Migration[5.0]
  def change
    create_table :monthly_global_data do |t|
      t.references :organization, foreign_key: true, null: false
      t.date :month_date, null: false
      t.integer :num_workers

      t.timestamps
    end
    add_index :monthly_global_data, [ :organization_id, :month_date ], unique: true
  end
end
