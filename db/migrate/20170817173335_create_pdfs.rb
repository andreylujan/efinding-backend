class CreatePdfs < ActiveRecord::Migration[5.0]
  def change
    create_table :pdfs do |t|
      t.references :organization, foreign_key: true, null: false
      t.text :pdf

      t.timestamps
    end
  end
end
