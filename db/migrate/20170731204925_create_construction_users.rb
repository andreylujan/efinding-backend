# -*- encoding : utf-8 -*-
class CreateConstructionUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :construction_users do |t|
      t.references :construction, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
    add_index :construction_users, [ :construction_id, :user_id ], unique: true
  end
end
