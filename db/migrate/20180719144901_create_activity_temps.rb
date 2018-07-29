class CreateActivityTemps < ActiveRecord::Migration[5.0]
  def change
    create_table :activity_temps do |t|
      t.string :datapart
      t.jsonb :activity
      t.belongs_to :report, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
