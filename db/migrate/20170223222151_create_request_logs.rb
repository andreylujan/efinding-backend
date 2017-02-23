class CreateRequestLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :request_logs do |t|
      t.references :organization, foreign_key: true, null: false
      t.text :url, null: false
      t.integer :status_code
      t.text :response_body
      t.json :error_messages

      t.timestamps
    end
  end
end
